//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SwiftUI
import XcodeObject

@Reducer
public struct DebugReducer {
    public init() {}

    @ObservableState
    public struct State {
        var lspClient: LSPClientDebugger.State
        var sourceFileClient: SourceFileClientDebugger.State
        var typeAnnotationClient: TypeAnnotationDebugger.State
        var kittenClient: SourceKitClientDebugger.State

        public init(
            lspClient: LSPClientDebugger.State,
            sourceFileClient: SourceFileClientDebugger.State,
            typeAnnotationClient: TypeAnnotationDebugger.State,
            kittenClient: SourceKitClientDebugger.State
        ) {
            self.lspClient = lspClient
            self.sourceFileClient = sourceFileClient
            self.typeAnnotationClient = typeAnnotationClient
            self.kittenClient = kittenClient
        }
    }

    public enum Action {
        case lspClient(LSPClientDebugger.Action)
        case sourceFileClient(SourceFileClientDebugger.Action)
        case typeAnnotationClient(TypeAnnotationDebugger.Action)
        case kittenClient(SourceKitClientDebugger.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.lspClient, action: \.lspClient) {
            LSPClientDebugger()
        }
        Scope(state: \.sourceFileClient, action: \.sourceFileClient) {
            SourceFileClientDebugger()
        }
        Scope(state: \.typeAnnotationClient, action: \.typeAnnotationClient) {
            TypeAnnotationDebugger()
        }
        Scope(state: \.kittenClient, action: \.kittenClient) {
            SourceKitClientDebugger()
        }
        Reduce { state, action in
            switch action {
            case .lspClient:
                return .none

            case let .sourceFileClient(.sourceFileResponse(.success(directory))):
                state.kittenClient.allFilePathsInProject = getAllSwiftFilePathsInProject(in: directory)
                return .none

            case let .sourceFileClient(.selectButtonTapped(sourceFile)):
                state.lspClient.rootPathString = state.sourceFileClient.rootPath
                state.lspClient.filePathString = sourceFile.path
                state.lspClient.sourceCode = sourceFile.content

                state.typeAnnotationClient.sourceFile = sourceFile

                state.kittenClient.filePath = sourceFile.path
                state.kittenClient.countedString = sourceFile.content

                return .none

            case .sourceFileClient:
                return .none

            case .typeAnnotationClient:
                return .none

            case .kittenClient:
                return .none
            }
        }
    }
}

extension DebugReducer {
    func getAllSwiftFilePathsInProject(in directory: Directory) -> [String] {
        var swiftFilePaths: [String] = directory.files.map { $0.path }
        for subDirectory in directory.subDirectories {
            swiftFilePaths.append(contentsOf: getAllSwiftFilePathsInProject(in: subDirectory))
        }
        return swiftFilePaths
    }
}

public struct DebugView: View {
    let store: StoreOf<DebugReducer>

    public init(store: StoreOf<DebugReducer>) {
        self.store = store
    }

    public var body: some View {
        TabView {
            SourceFileClientDebugView(
                store: store.scope(
                    state: \.sourceFileClient,
                    action: \.sourceFileClient
                )
            )
            .tabItem { Text("SourceFileClient") }
            .padding()

            LSPClientDebugView(
                store: store.scope(
                    state: \.lspClient,
                    action: \.lspClient
                )
            )
            .tabItem { Text("LSPClient") }
            .padding()

            TypeAnnotationDebugView(
                store: store.scope(
                    state: \.typeAnnotationClient,
                    action: \.typeAnnotationClient
                )
            )
            .tabItem { Text("TypeAnnotationClient") }
            .padding()

            SourceKitClientDebugView(
                store: store.scope(
                    state: \.kittenClient,
                    action: \.kittenClient
                )
            )
            .tabItem { Text("SourceKitClient") }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}
