//
//  SourceCodeClient.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SourceCodeClient
import SwiftUI

@Reducer
public struct SourceCodeClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var rootPathString: String

        public init(rootPathString: String) {
            self.rootPathString = rootPathString
        }
    }

    public enum Action: BindableAction {
        case subPathsButtonTapped
        case binding(BindingAction<State>)
    }

    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .subPathsButtonTapped:
                return .run { [rootPathString = state.rootPathString] _ in
                    try await _ = sourceFileClient.getSourceFiles(
                        rootDirectoryPath: rootPathString,
                        ignoredDirectories: [".build", "DerivedData"]
                    )
                }

            case .binding:
                return .none
            }
        }
    }
}

public struct SourceCodeClientDebugView: View {
    @Bindable public var store: StoreOf<SourceCodeClientDebugger>

    public init(store: StoreOf<SourceCodeClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        Form {
            TextField("Project root path", text: $store.rootPathString)
            Button("Get Sub Paths") {
                store.send(.subPathsButtonTapped)
            }
        }
    }
}
