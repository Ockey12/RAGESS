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
        var sourceFileClient: SourceFileClientDebugger.State

        public init(
            lspClient: LSPClientDebugger.State,
            sourceFileClient: SourceFileClientDebugger.State
        ) {
            self.lspClient = lspClient
            self.sourceFileClient = sourceFileClient
        }
    }

    public enum Action {
        case lspClient(LSPClientDebugger.Action)
        case sourceFileClient(SourceFileClientDebugger.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.lspClient, action: \.lspClient) {
            LSPClientDebugger()
        }
        Scope(state: \.sourceFileClient, action: \.sourceFileClient) {
            SourceFileClientDebugger()
        }
        Reduce { state, action in
            switch action {
            case .lspClient:
                return .none

            case let .sourceFileClient(.selectButtonTapped(sourceFile)):
                state.lspClient.rootPathString = state.sourceFileClient.rootPathString
                state.lspClient.filePathString = sourceFile.path
                state.lspClient.sourceCode = sourceFile.content
                return .none

            case .sourceFileClient:
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
            .tabItem { Text("LSPclient") }
            .padding()
        }
        .frame(width: 800)
    }
}
