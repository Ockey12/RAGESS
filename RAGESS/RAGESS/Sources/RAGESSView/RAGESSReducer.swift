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
        var loadingTaskKindBuffer: [LoadingTaskKind] = []

        public init(projectRootDirectoryPath: String) {
            self.projectRootDirectoryPath = projectRootDirectoryPath
        }
    }

    public enum Action: BindableAction {
        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case sourceFileResponse(Result<Directory, Error>)
        case sourceFileSelected(SourceFile)
        case buildSettingsResponse(Result<[String: String], Error>)
        case dumpPackageResponse(Result<PackageObject, Error>)
        case dumpPackageCompleted
        case extractDeclarationsCompleted([any DeclarationObject])
        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient
    @Dependency(BuildSettingsClient.self) var buildSettingsClient
    @Dependency(DumpPackageClient.self) var dumpPackageClient
    @Dependency(DependenciesClient.self) var dependenciesClient

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
                state.loadingTaskKindBuffer.append(.sourceFiles)

                return .run { [projectRootDirectoryPath = state.projectRootDirectoryPath] send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: projectRootDirectoryPath,
                            ignoredDirectories: [
                                "build",
                                ".build",
                                "DerivedData",
                                ".git",
                                ".github",
                                ".swiftpm"
                            ]
                        )
                    }))
                }

            case let .projectDirectorySelectorResponse(.failure(error)):
                print(error)
                return .none

            case let .sourceFileResponse(.success(rootDirectory)):
                #if DEBUG
                    print(".sourceFileResponse(.success(rootDirectory))")
                    dump(rootDirectory)
                #endif

                state.rootDirectory = rootDirectory
                state.loadingTaskKindBuffer.removeFirst()

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
                    dump(packageObject)
                #endif

                return .none

            case let .dumpPackageResponse(.failure(error)):
                print(error)
                return .none

            case .dumpPackageCompleted:
#if DEBUG
                print("Successfully dump all `PackageObject`.")
#endif

                guard let rootDirectory = state.rootDirectory else {
                    print("ERROR in \(#file) - \(#line): Cannot find `State.rootDirectory`")
                    return .none
                }
                let allSourceFiles = getAllSourceFiles(in: rootDirectory)

                return .run {
                    [
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in

                    let declarationObjects = await extractDeclarations(
                        allSourceFiles: allSourceFiles,
                        buildSettings: buildSettings,
                        packages: packages)

                    await send(.extractDeclarationsCompleted(declarationObjects))
                }

            case let .extractDeclarationsCompleted(declarationObjects):
#if DEBUG
                print("Successfully extract declaration objects.")
#endif

                guard let rootDirectory = state.rootDirectory else {
                    print("ERROR in \(#file) - \(#line): Cannot find `State.rootDirectory`")
                    return .none
                }
                let allSourceFiles = getAllSourceFiles(in: rootDirectory)


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
#if DEBUG
                print("Successfully extract dependencies.")
#endif

                state.declarationObjects = hasDependenciesObjects
                dump(state.declarationObjects)
                return .none

            case let .extractDependenciesResponse(.failure(error)):
                print(error)
                return .none

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
}
