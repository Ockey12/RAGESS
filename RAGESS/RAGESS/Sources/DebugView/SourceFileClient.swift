//
//  SourceFileClient.swift
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
        var sourceFiles: [SourceFile]

        public init(
            rootPathString: String,
            sourceFiles: [SourceFile]
        ) {
            self.rootPathString = rootPathString
            self.sourceFiles = sourceFiles
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case sourceFileResponse(Result<[SourceFile], Error>)
        case binding(BindingAction<State>)
    }

    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .getSourceFilesButtonTapped:
                return .run { [rootPathString = state.rootPathString] send in
                    await send(.sourceFileResponse(Result{
                        try await sourceFileClient.getSourceFiles(
                            rootDirectoryPath: rootPathString,
                            ignoredDirectories: [".build", "DerivedData"])
                    }))
                }

            case let .sourceFileResponse(.success(sourceFiles)):
                state.sourceFiles = sourceFiles
                return .none

            case .sourceFileResponse(.failure):
                return .none

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
        VStack {
            Form {
                TextField("Project root path", text: $store.rootPathString)
                Button("Get Source Files") {
                    store.send(.getSourceFilesButtonTapped)
                }
            }

            ScrollView {
                ForEach(store.sourceFiles, id: \.path) { sourceFile in
                    DisclosureGroup(sourceFile.path) {
                        HStack {
                            Text(sourceFile.content)
                                .padding(.leading)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .background(.black)
                        .padding(.leading)
                    }
                }
            }
        }
    }
}
