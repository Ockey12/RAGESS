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
import XcodeObject

@Reducer
public struct RAGESSReducer {
    public init() {}

    @ObservableState
    public struct State {
        struct ExtractedData: Equatable {
            var projectRootDirectoryPath: String = ""
            var derivedDataPath: String = ""
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

        var showStopButton = false
        var extractedData: ExtractedData = .init()
        var rootDirectoryWithoutUSRs: Directory?
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
        var processStartTime = CFAbsoluteTimeGetCurrent()
        var debugView = DebugReducer.State()

        var lastBuildStartTimeString = ""
        var lastBuildSuccessTimeString = ""
        let dateFormatter: DateFormatter
        let monitor = BuildMonitor()
        var isMonitoring = false

        var lastSelectedObjectUSR: String?

        public init() {
            dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .short
            dateFormatter.locale = .current
        }
    }

    public enum Action: BindableAction {
        case task

        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case derivedDataSelectorResponse(Result<[URL], Error>)
        case startButtonTapped
        case stopButtonTapped
        case extractSourceFiles
        case sourceFileResponse(Result<Directory, Error>)
        case declarationExtractorResponse(Result<DeclarationExtractor.Response, Error>)
        case dependenciesExtractorCompleted([DependencyObject])

        case detectedBuildStart(Date)
        case detectedBuildSuccess(Date)

        case fileTree(FileTreeViewReducer.Action)
        case swiftDiagramTree(SwiftDiagramTreeViewReducer.Action)
        case minusMagnifyingglassTapped
        case plusMagnifyingglassTapped
        case debugView(DebugReducer.Action)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient
    @Dependency(\.swiftIndexStoreClient) private var indexStoreClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
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
            case .task:
                return .run { send in
                    for await event in BuildMonitor().monitorBuildEvents() {
                        switch event {
                        case let .buildStart(date):
                            await send(.detectedBuildStart(date))
                        case let .buildSuccess(date):
                            await send(.detectedBuildSuccess(date))
                        }
                    }
                }

            case let .projectDirectorySelectorResponse(result):
                switch result {
                case let .success(urls):
                    guard let url = urls.first else {
                        assertionFailure()
                        return .none
                    }

                    state.extractedData.projectRootDirectoryPath = url.path()

                    return .none

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case let .derivedDataSelectorResponse(result):
                switch result {
                case let .success(urls):
                    guard let url = urls.first else {
                        assertionFailure()
                        return .none
                    }

                    state.extractedData.derivedDataPath = url.path()

                    return .none

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
                }

            case .startButtonTapped:
                guard state.extractedData.projectRootDirectoryPath != "",
                      state.extractedData.derivedDataPath != "" else {
                    return .none
                }

                state.showStopButton = true
                state.isMonitoring = true

                return .none

            case .stopButtonTapped:
                state.showStopButton = false
                state.isMonitoring = false
                state.rootDirectoryWithoutUSRs = nil

                return .none

            case .extractSourceFiles:
                state.processStartTime = CFAbsoluteTimeGetCurrent()

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
                    state.rootDirectoryWithoutUSRs = rootDirectory
                    return .none

                case let .failure(error):
                    print(error)
                    assertionFailure()
                    return .none
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
                print("EXTRACT COMPLETED: \(CFAbsoluteTimeGetCurrent() - state.processStartTime) S")

                if let usr = state.lastSelectedObjectUSR,
                   let objectKeyPath = state.extractedData.usrTable[usr],
                   let rootDirectory = state.extractedData.rootDirectory {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    state.swiftDiagramTree = .init(
                        rootObjectKeyPath: objectKeyPath,
                        rootDirectory: rootDirectory,
                        usrTable: state.extractedData.usrTable,
                        dependencyObjects: state.extractedData.dependencyObjects
                    )
                    print("Node States Generated: \(CFAbsoluteTimeGetCurrent() - startTime) S")
                } else {
                    state.swiftDiagramTree.reset()
                }
                return .none

            case let .detectedBuildStart(date):
                guard state.isMonitoring else {
                    return .none
                }

                let dateString = state.dateFormatter.string(from: date)
                print("Build Start: \(dateString)")
                state.lastBuildStartTimeString = dateString
                return .send(.extractSourceFiles)

            case let .detectedBuildSuccess(date):
                guard state.isMonitoring else {
                    return .none
                }

                let dateString = state.dateFormatter.string(from: date)
                print("Build Success: \(dateString)")
                state.lastBuildSuccessTimeString = dateString

                guard let rootDirectory = state.rootDirectoryWithoutUSRs else {
                    print("state.rootDirectoryWithoutUSRs == nil")
                    return .run { send in
                        try await Task.sleep(for: .seconds(1))
                        await send(.detectedBuildSuccess(date))
                    }
                }
                state.rootDirectoryWithoutUSRs = nil
                guard !rootDirectory.allXcodeprojPathsUnderDirectory.isEmpty,
                      let derivedDataURL = URL(string: state.extractedData.derivedDataPath)
                else {
                    assertionFailure()
                    return .none
                }

                let indexStoreURL = derivedDataURL
                    .appendingPathComponent("Index.noindex")
                    .appendingPathComponent("DataStore")

                return .run { send in
                    await send(.declarationExtractorResponse(Result {
                        try DeclarationExtractor.extractDeclarations(rootDirectory: rootDirectory, indexStoreURL: indexStoreURL)
                    }))
                }

            // MARK: Children Actions

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
                    state.lastSelectedObjectUSR = firstUSR
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
                state.swiftDiagramTree.swiftDiagramScale = max(round((state.swiftDiagramTree.swiftDiagramScale - 0.1) * 10) / 10, 0.1)
                return .none

            case .plusMagnifyingglassTapped:
                state.swiftDiagramTree.swiftDiagramScale = min(round((state.swiftDiagramTree.swiftDiagramScale + 0.1) * 10) / 10, 2)
                return .none

            case .debugView:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
