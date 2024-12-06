//
//  RAGESSReducer.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import BuildSettingsClient
import ComposableArchitecture
import DebugView
import DeclarationExtractor
import DeclaredObject
import Dependencies
import DependenciesExtractor
import DependencyObject
import DumpPackageClient
import FileTreeView
import Foundation
import MonitorClient
import SourceFileClient
import SwiftDiagramView
import SwiftIndexStoreObject

// import TypeDeclaration
import XcodeObject

@Reducer
public struct RAGESSReducer {
    public init() {}

    @ObservableState
    public struct State {
        struct ExtractedData {
            var projectRootDirectoryPath: String = ""
            var rootDirectory: Directory?
            var buildSettings: [String: String] = [:]
            var packages: [PackageObject] = []
            var usrTable: [String: WritableKeyPath<Directory, DeclaredObject>] = [:]
            var sourceFileTable: [String: WritableKeyPath<Directory, SourceFile>] = [:]
            var indexStoreObjects: [IndexStoreObject] = []
            var dependencyObjects: [DependencyObject] = []

            mutating func reset() {
                rootDirectory = nil
                buildSettings = [:]
                packages = []
                usrTable = [:]
                sourceFileTable = [:]
                indexStoreObjects = []
            }
        }

        var extractedData: ExtractedData = .init()
        let ignoredDirectories = [
            "build",
            ".build",
            "DerivedData",
            ".git",
            ".github",
            ".swiftpm"
        ]
        var fileTree: FileTreeViewReducer.State = .init()
        var loadingTaskKindBuffer: [LoadingTaskKind] = []
        var swiftDiagramTree: SwiftDiagramTreeViewReducer.State = .init(
            rootObjectKeyPath: nil,
            rootDirectory: nil,
            usrTable: [:],
            dependencyObjects: []
        )
        var swiftDiagramScale: CGFloat = 0.5
        var processStartTime = CFAbsoluteTimeGetCurrent()
        var debugView = DebugReducer.State()

        public init() {}
    }

    public enum Action: BindableAction {
        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case extractSourceFiles
        case sourceFileResponse(Result<Directory, Error>)
        case buildSettingsResponse(Result<[String: String], Error>)
        case dumpPackageResponse(Result<PackageObject, Error>)
        case dumpPackageCompleted(rootDirectory: Directory)
        case declarationExtractorResponse(Result<DeclarationExtractor.Response, Error>)
        case dependenciesExtractorCompleted([DependencyObject])

//        case extractDeclarationsCompleted([any DeclarationObject])
//        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
        case startMonitoring
        case detectedDirectoryChange
        case fileTree(FileTreeViewReducer.Action)
        case swiftDiagramTree(SwiftDiagramTreeViewReducer.Action)
        case minusMagnifyingglassTapped
        case plusMagnifyingglassTapped
        case debugView(DebugReducer.Action)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient
    @Dependency(BuildSettingsClient.self) var buildSettingsClient
    @Dependency(DumpPackageClient.self) var dumpPackageClient
    @Dependency(\.swiftIndexStoreClient) private var indexStoreClient
    @Dependency(\.mainQueue) var mainQueue

    enum CancelID {
        case detectedBuildSucceeded
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.fileTree, action: \.fileTree) {
            FileTreeViewReducer()
        }
        Scope(state: \.swiftDiagramTree, action: \.swiftDiagramTree) {
            SwiftDiagramTreeViewReducer()
        }
        #if DEBUG
            Scope(state: \.debugView, action: \.debugView) {
                DebugReducer()
            }
        #endif
        Reduce { state, action in
            switch action {
            case let .projectDirectorySelectorResponse(result):
                switch result {
                case let .success(urls):
                    guard let url = urls.first else {
                        assertionFailure()
                        return .none
                    }

                    state.extractedData.projectRootDirectoryPath = url.path()

                    return .send(.extractSourceFiles)

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case .extractSourceFiles:
                state.processStartTime = CFAbsoluteTimeGetCurrent()
                state.loadingTaskKindBuffer.append(.sourceFiles)

                return .run { [
                    projectRootDirectoryPath = state.extractedData.projectRootDirectoryPath,
                    ignoredDirectories = state.ignoredDirectories
                ] send in
                    await send(.sourceFileResponse(Result {
                        try sourceFileClient.getRootDirectory(
                            rootDirectoryPath: projectRootDirectoryPath,
                            ignoredDirectories: ignoredDirectories
                        )
                    }))
                }

            case let .sourceFileResponse(result):
                switch result {
                case let .success(rootDirectory):
                    state.loadingTaskKindBuffer.removeFirst()

                    guard !rootDirectory.allXcodeprojPathsUnderDirectory.isEmpty else {
                        assertionFailure()
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
                                // TODO: support for multiple xcodeproj
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

                        await send(.dumpPackageCompleted(rootDirectory: rootDirectory))
                    }

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case let .buildSettingsResponse(result):
                switch result {
                case let .success(buildSettings):
                    state.extractedData.buildSettings = buildSettings
                    state.loadingTaskKindBuffer.removeFirst()
                    return .none

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case let .dumpPackageResponse(result):
                switch result {
                case let .success(packageObject):
                    state.extractedData.packages.append(packageObject)
                    state.loadingTaskKindBuffer.removeFirst()
                    return .none

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case let .dumpPackageCompleted(rootDirectory: rootDirectory):
                state.loadingTaskKindBuffer.removeAll(where: { $0 == .dumpPackage })

                // example: BUILD_DIR: ~/Library/Developer/Xcode/DerivedData/<project hash>/Build/Products
                guard let buildProductsPath = state.extractedData.buildSettings["BUILD_DIR"] else {
                    assertionFailure()
                    return .none
                }
                guard let derivedDataURL = URL(string: buildProductsPath)?.deletingLastPathComponent().deletingLastPathComponent() else {
                    assertionFailure()
                    return .none
                }
                let indexStoreURL = derivedDataURL
                    .appendingPathComponent("Index.noindex")
                    .appendingPathComponent("DataStore")

                state.loadingTaskKindBuffer.append(.extractDeclarations)

                return .run { send in
                    await send(.declarationExtractorResponse(Result {
                        try DeclarationExtractor.extractDeclarations(rootDirectory: rootDirectory, indexStoreURL: indexStoreURL)
                    }))
                }

            case let .declarationExtractorResponse(result):
                switch result {
                case let .success(response):
                    state.extractedData.rootDirectory = response.rootDirectory
                    state.extractedData.usrTable = response.usrTable
                    state.extractedData.sourceFileTable = response.sourceFileTable
                    state.extractedData.indexStoreObjects = response.indexStoreObjects

                    state.fileTree.rootDirectory = response.rootDirectory

                    return .send(.dependenciesExtractorCompleted(
                        DependenciesExtractor.extract(
                            indexStoreObjects: response.indexStoreObjects,
                            usrTable: response.usrTable,
                            sourceFileTable: response.sourceFileTable,
                            rootDirectory: response.rootDirectory
                        )
                    ))

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case let .dependenciesExtractorCompleted(dependencyObjects):
                state.extractedData.dependencyObjects = dependencyObjects
                return .none

            case .startMonitoring:
                guard let buildDirectoryPath = state.extractedData.buildSettings["BUILD_DIR"] else {
                    assertionFailure()
                    return .none
                }
                let appPaths = findAppPaths(in: buildDirectoryPath)

                guard !appPaths.isEmpty else {
                    assertionFailure()
                    return .none
                }

                return .run { send in
                    // FIXME: Monitoring multiple `.app` directories.
                    // FIXME: Reset monitoring if project root directory changes.
                    for await _ in monitorClient.start(directoryPath: appPaths[0]) {
                        await send(.detectedDirectoryChange)
                    }
                }

            case .detectedDirectoryChange:
                return .send(.extractSourceFiles)
                    .debounce(
                        id: CancelID.detectedBuildSucceeded,
                        for: 1.0,
                        scheduler: self.mainQueue
                    )

            case let .fileTree(.delegate(delegateAction)):
                switch delegateAction {
                case let .popoverCellClicked(firstUSR: firstUSR):
                    guard let objectKeyPath = state.extractedData.usrTable[firstUSR],
                          let rootDirectory = state.extractedData.rootDirectory
                    else {
                        assertionFailure()
                        return .none
                    }
                    let selectedObject = rootDirectory[keyPath: objectKeyPath]
                    print("Selected: \(selectedObject.name)")

                    let startTime = CFAbsoluteTimeGetCurrent()
                    state.swiftDiagramTree = .init(
                        rootObjectKeyPath: objectKeyPath,
                        rootDirectory: rootDirectory,
                        usrTable: state.extractedData.usrTable,
                        dependencyObjects: state.extractedData.dependencyObjects
                    )
                    print("Node States Generated: \(CFAbsoluteTimeGetCurrent() - startTime) S")

                    return .none
                }

            case .fileTree:
                return .none

            case .swiftDiagramTree:
                return .none

            case .minusMagnifyingglassTapped:
                state.swiftDiagramScale = max(state.swiftDiagramScale - 0.05, 0.05)
                return .none

            case .plusMagnifyingglassTapped:
                state.swiftDiagramScale = min(state.swiftDiagramScale + 0.05, 1)
                return .none

            case .debugView:
                return .none

            case .binding:
                return .none
            }
        }
    }
}

extension RAGESSReducer {
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
