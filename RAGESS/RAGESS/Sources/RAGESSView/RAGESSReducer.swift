//
//  RAGESSReducer.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import BuildSettingsClient
import ComposableArchitecture
import DeclarationExtractor
import Dependencies
import DependenciesClient
import DumpPackageClient
import Foundation
import MonitorClient
import SourceFileClient
import TypeDeclaration
import XcodeObject

@Reducer
public struct RAGESSReducer {
    public init() {}

    @ObservableState
    public struct State {
        var projectRootDirectoryPath: String
        var rootDirectory: Directory?
        var buildSettings: [String: String] = [:]
        var packages: [PackageObject] = []
        var declarationObjects: [any DeclarationObject] = []
        let ignoredDirectories = [
            "build",
            ".build",
            "DerivedData",
            ".git",
            ".github",
            ".swiftpm"
        ]
        var loadingTaskKindBuffer: [LoadingTaskKind] = []

        public init(projectRootDirectoryPath: String) {
            self.projectRootDirectoryPath = projectRootDirectoryPath
        }
    }

    public enum Action: BindableAction {
        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case extractSourceFiles
        case sourceFileResponse(Result<Directory, Error>)
        case sourceFileSelected(SourceFile)
        case buildSettingsResponse(Result<[String: String], Error>)
        case dumpPackageResponse(Result<PackageObject, Error>)
        case dumpPackageCompleted
        case extractDeclarationsCompleted([any DeclarationObject])
        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
        case startMonitoring
        case detectedDirectoryChange
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient
    @Dependency(BuildSettingsClient.self) var buildSettingsClient
    @Dependency(DumpPackageClient.self) var dumpPackageClient
    @Dependency(DependenciesClient.self) var dependenciesClient
    @Dependency(\.mainQueue) var mainQueue

    enum CancelID {
        case detectedBuildSucceeded
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .projectDirectorySelectorResponse(.success(urls)):
                guard let url = urls.first else {
                    print("ERROR in \(#file) - \(#line): Cannot find `urls.first`")
                    return .none
                }

                #if DEBUG
                    print("Successfully get project root directory path.")
                    print("╰─\(url.path())")
                #endif

                state.projectRootDirectoryPath = url.path()

                return .send(.extractSourceFiles)

            case let .projectDirectorySelectorResponse(.failure(error)):
                print(error)
                return .none

            case .extractSourceFiles:
                state.loadingTaskKindBuffer.append(.sourceFiles)

                return .run { [
                    projectRootDirectoryPath = state.projectRootDirectoryPath,
                    ignoredDirectories = state.ignoredDirectories
                ] send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: projectRootDirectoryPath,
                            ignoredDirectories: ignoredDirectories
                        )
                    }))
                }

            case let .sourceFileResponse(.success(rootDirectory)):
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print(".sourceFileResponse(.success(rootDirectory))")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                    dump(rootDirectory)
                #endif

                state.rootDirectory = rootDirectory

                guard !rootDirectory.allXcodeprojPathsUnderDirectory.isEmpty else {
                    print("ERROR in \(#file) - \(#line): Cannot find `**.xcodeproj`")
                    return .none
                }

                state.loadingTaskKindBuffer.append(.buildSettings)
                state.loadingTaskKindBuffer.append(
                    contentsOf: Array(
                        repeating: .dumpPackage,
                        count: rootDirectory.allPackageSwiftPath.count
                    )
                )

                return .run { send in
                    await send(.buildSettingsResponse(Result {
                        try await buildSettingsClient.getSettings(
                            xcodeprojPath: rootDirectory.allXcodeprojPathsUnderDirectory[0]
                        )
                    }))

                    for packageSwiftPath in rootDirectory.allPackageSwiftPath {
                        let packageDirectoryPath = NSString(string: packageSwiftPath)
                            .deletingLastPathComponent
                        await send(.dumpPackageResponse(Result {
                            try await dumpPackageClient.dumpPackage(currentDirectory: packageDirectoryPath)
                        }))
                    }

                    await send(.dumpPackageCompleted)
                }

            case let .sourceFileResponse(.failure(error)):
                print(error)
                return .none

            case let .sourceFileSelected(sourceFile):
                return .none

            case let .buildSettingsResponse(.success(buildSettings)):
                state.buildSettings = buildSettings
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print("Successfully get buildsettings.")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                    dump(buildSettings)
                #endif
                return .none

            case let .buildSettingsResponse(.failure(error)):
                print(error)
                return .none

            case let .dumpPackageResponse(.success(packageObject)):
                state.packages.append(packageObject)
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print("Successfully dump `PackageObject`.")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                    dump(packageObject)
                #endif

                return .none

            case let .dumpPackageResponse(.failure(error)):
                print(error)
                return .none

            case .dumpPackageCompleted:
                state.loadingTaskKindBuffer.removeAll(where: { $0 == .dumpPackage })

                #if DEBUG
                    print("Successfully dump all `PackageObject`.")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                #endif

                guard let rootDirectory = state.rootDirectory else {
                    print("ERROR in \(#file) - \(#line): Cannot find `State.rootDirectory`")
                    return .none
                }
                let allSourceFiles = getAllSourceFiles(in: rootDirectory)

                state.loadingTaskKindBuffer.append(.extractDeclarations)

                return .run {
                    [
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in

                    let declarationObjects = await extractDeclarations(
                        allSourceFiles: allSourceFiles,
                        buildSettings: buildSettings,
                        packages: packages
                    )

                    await send(.extractDeclarationsCompleted(declarationObjects))
                }

            case let .extractDeclarationsCompleted(declarationObjects):
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print("Successfully extract declaration objects.")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                #endif

                guard let rootDirectory = state.rootDirectory else {
                    print("ERROR in \(#file) - \(#line): Cannot find `State.rootDirectory`")
                    return .none
                }
                let allSourceFiles = getAllSourceFiles(in: rootDirectory)

                state.loadingTaskKindBuffer.append(.extractDependencies)

                return .run {
                    [
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in

                    await send(.extractDependenciesResponse(Result {
                        try await dependenciesClient.extractDependencies(
                            declarationObjects: declarationObjects,
                            allSourceFiles: allSourceFiles,
                            buildSettings: buildSettings,
                            packages: packages
                        )
                    }))
                }

            case let .extractDependenciesResponse(.success(hasDependenciesObjects)):
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print("Successfully extract dependencies.")
                    print("state.loadingTaskKindBuffer.removeFirst(): \(state.loadingTaskKindBuffer)")
                #endif

                state.declarationObjects = hasDependenciesObjects
                return .send(.startMonitoring)

            case let .extractDependenciesResponse(.failure(error)):
                print(error)
                return .none

            case .startMonitoring:
                guard let buildDirectoryPath = state.buildSettings["BUILD_DIR"] else {
                    #if DEBUG
                        print("ERROR in \(#file) - \(#line): Cannot \"BUILD_DIR\" key.")
                    #endif
                    return .none
                }
                let appPaths = findAppPaths(in: buildDirectoryPath)

                return .run { send in
                    for appPath in appPaths {
                        for await _ in monitorClient.start(directoryPath: appPath) {
                            await send(.detectedDirectoryChange)
                        }
                    }
                }

            case .detectedDirectoryChange:
                return .send(.extractSourceFiles)
                    .debounce(
                        id: CancelID.detectedBuildSucceeded,
                        for: 1.0,
                        scheduler: self.mainQueue
                    )

            case .binding:
                return .none
            }
        }
    }
}

extension RAGESSReducer {
    func getAllSourceFiles(in directory: Directory) -> [SourceFile] {
        var files = directory.files
        for subDirectory in directory.subDirectories {
            files.append(contentsOf: getAllSourceFiles(in: subDirectory))
        }
        return files
    }

    func getAllSwiftFilePaths(in directory: Directory) -> [String] {
        var swiftFilePaths: [String] = directory.files.map { $0.path }
        for subDirectory in directory.subDirectories {
            swiftFilePaths.append(contentsOf: getAllSwiftFilePaths(in: subDirectory))
        }
        return swiftFilePaths
    }

    func extractDeclarations(
        allSourceFiles: [SourceFile],
        buildSettings: [String: String],
        packages: [PackageObject]
    ) async -> [any DeclarationObject] {
        var declarationObjects: [any DeclarationObject] = []
        let allSourceFilePaths = allSourceFiles.map { $0.path }
        let extractor = DeclarationExtractor()

        for sourceFile in allSourceFiles {
            let declarations = await extractor.extractDeclarations(
                from: sourceFile,
                buildSettings: buildSettings,
                sourceFilePaths: allSourceFilePaths,
                packages: packages
            )

            declarationObjects.append(contentsOf: declarations)
        }

        return declarationObjects
    }

    func findAppPaths(in directoryPath: String) -> [String] {
        let fileManager = FileManager.default
        let directoryURL = URL(filePath: directoryPath)

        guard let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }

        var appPaths: [String] = []

        while let url = enumerator.nextObject() as? URL {
            if url.pathExtension == "app" {
                appPaths.append(url.path())
            }
        }

        return appPaths
    }
}
