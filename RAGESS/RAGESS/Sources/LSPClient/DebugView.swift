//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/11.
//

import ComposableArchitecture
import LanguageServerProtocol
import SwiftUI

@Reducer
public struct DebugReducer {
    public init() {}

    @ObservableState
    public struct State {
        let serverPathString = "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp"
        var rootPathString: String
        var filePathString: String
        var sourceCode: String
        var row: Int
        var column: Int

        public init(
            rootPathString: String,
            filePathString: String,
            sourceCode: String,
            row: Int,
            column: Int
        ) {
            self.rootPathString = rootPathString
            self.filePathString = filePathString
            self.sourceCode = sourceCode
            self.row = row
            self.column = column
        }
    }

    public enum Action: BindableAction {
        case sendInitializeRequest
        case sendInitializedNotification
        case sendDidOpenNotification
        case sendDefinitionRequest
        case binding(BindingAction<State>)
    }

    @Dependency(LSPClient.self) var lspClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .sendInitializeRequest:
                return .run { [
                    serverPath = state.serverPathString,
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

            case .sendDefinitionRequest:
                return .run { [
                    filePathString = state.filePathString,
                    row = state.row,
                    column = state.column
                ] _ in
                    let position = Position(line: row, utf16index: column)
                    try await lspClient.sendDefinitionRequest(
                        filePathString: filePathString,
                        position: position
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

            Section {
                HStack {
                    Picker("Line", selection: $store.row) {
                        ForEach(0...100, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .frame(width: 100)
                    Picker("utf16index", selection: $store.column) {
                        ForEach(0...100, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .frame(width: 130)
                }
                Button("Send Definition Request") {
                    store.send(.sendDefinitionRequest)
                }
            } header: {
                Text("Definition")
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
                sourceCode: "",
                row: 0,
                column: 0
            ),
            reducer: {
                DebugReducer()
            }
        )
    )
}
