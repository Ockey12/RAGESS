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
        var filePathString: String
        var sourceCode: String

        public init(rootPathString: String, filePathString: String, sourceCode: String) {
            self.rootPathString = rootPathString
            self.filePathString = filePathString
            self.sourceCode = sourceCode
        }
    }

    public enum Action: BindableAction {
        case sendInitializeRequest
        case sendInitializedNotification
        case sendDidOpenNotification
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

            case .sendDidOpenNotification:
                return .run { [
                    filePathString = state.filePathString,
                    sourceCode = state.sourceCode
                ] _ in
                    try await lspClient.sendDidOpenNotification(
                        filePathString: filePathString,
                        sourceCode: sourceCode
                    )
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

            Section {
                TextField("File path", text: $store.filePathString)
                TextEditor(text: $store.sourceCode)
                    .frame(height: 300)
                Button("Send DidOpen Notification") {
                    store.send(.sendDidOpenNotification)
                }
            } header: {
                Text("DidOpen")
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
            initialState: DebugReducer.State(
                rootPathString: "",
                filePathString: "",
                sourceCode: ""
            ),
            reducer: {
                DebugReducer()
            }
        )
    )
}
