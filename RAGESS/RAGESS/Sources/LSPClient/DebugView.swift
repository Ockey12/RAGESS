//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/11.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct DebugReducer {
    public init() {}

    @ObservableState
    public struct State {
        let serverPath = "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp"
        var rootPathString: String

        public init(rootPathString: String) {
            self.rootPathString = rootPathString
        }
    }

    public enum Action: BindableAction {
        case sendInitializeRequest
        case sendInitializedNotification
        case binding(BindingAction<State>)
    }

    @Dependency(LSPClient.self) var lspClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .sendInitializeRequest:
                return .run { [
                    serverPath = state.serverPath,
                    projectRootPathString = state.rootPathString
                ] _ in
                    try await lspClient.sendInitializeRequest(
                        serverPath: serverPath,
                        projectRootPathString: projectRootPathString
                    )
                }

            case .sendInitializedNotification:
                return .run { _ in
                    try await lspClient.sendInitializedNotification()
                }

            case .binding:
                return .none
            }
        }
    }
}

public struct DebugView: View {
    @Bindable public var store: StoreOf<DebugReducer>

    public init(store: StoreOf<DebugReducer>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section {
                TextField("Project root path", text: $store.rootPathString)
                Button("Send Initialize Request") {
                    store.send(.sendInitializeRequest)
                }
                Button("Send Initialized Notification") {
                    store.send(.sendInitializedNotification)
                }
            } header: {
                Text("Initialization")
                    .font(.headline)
            }
        } // Form
        .padding()
        .frame(width: 800)
    } // body
}

#Preview {
    DebugView(
        store: .init(
            initialState: DebugReducer.State(rootPathString: ""),
            reducer: { DebugReducer() }
        )
    )
}
