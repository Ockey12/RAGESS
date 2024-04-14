//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct DebugReducer {
    public init() {}

    @ObservableState
    public struct State {
        var lspClient: LSPClientDebugger.State
        var sourceCodeClient: SourceCodeClientDebugger.State

        public init(
            lspClient: LSPClientDebugger.State,
            sourceCodeClient: SourceCodeClientDebugger.State
        ) {
            self.lspClient = lspClient
            self.sourceCodeClient = sourceCodeClient
        }
    }

    public enum Action {
        case lspClient(LSPClientDebugger.Action)
        case sourceCodeClient(SourceCodeClientDebugger.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.lspClient, action: \.lspClient) {
            LSPClientDebugger()
        }
        Scope(state: \.sourceCodeClient, action: \.sourceCodeClient) {
            SourceCodeClientDebugger()
        }
        Reduce { state, action in
            switch action {
            case .lspClient:
                return .none

            case let .sourceCodeClient(.selectButtonTapped(sourceFile)):
                state.lspClient.rootPathString = state.sourceCodeClient.rootPathString
                state.lspClient.filePathString = sourceFile.path
                state.lspClient.sourceCode = sourceFile.content
                return .none

            case .sourceCodeClient:
                return .none
            }
        }
    }
}

public struct DebugView: View {
    let store: StoreOf<DebugReducer>

    public init(store: StoreOf<DebugReducer>) {
        self.store = store
    }

    public var body: some View {
        TabView {
            SourceCodeClientDebugView(
                store: store.scope(
                    state: \.sourceCodeClient,
                    action: \.sourceCodeClient
                )
            )
            .tabItem { Text("SourceCodeClient") }
            .padding()

            LSPClientDebugView(
                store: store.scope(
                    state: \.lspClient,
                    action: \.lspClient
                )
            )
            .tabItem { Text("LSPclient") }
            .padding()
        }
        .frame(width: 800)
    }
}
