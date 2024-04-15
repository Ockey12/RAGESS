//
//  SourceFileClient.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SourceFileClient
import SwiftUI

@Reducer
public struct SourceFileClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var rootPathString: String
        var sourceFiles: IdentifiedArrayOf<SourceFile>

        public init(
            rootPathString: String,
            sourceFiles: IdentifiedArrayOf<SourceFile>
        ) {
            self.rootPathString = rootPathString
            self.sourceFiles = sourceFiles
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case sourceFileResponse(Result<IdentifiedArrayOf<SourceFile>, Error>)
        case selectButtonTapped(SourceFile)
        case binding(BindingAction<State>)
    }

    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .getSourceFilesButtonTapped:
                return .run { [rootPathString = state.rootPathString] send in
                    await send(.sourceFileResponse(Result {
                        try await IdentifiedArray(
                            uniqueElements: sourceFileClient.getSourceFiles(
                                rootDirectoryPath: rootPathString,
                                ignoredDirectories: [".build", "DerivedData"]
                            )
                        )
                    }))
                }

            case let .sourceFileResponse(.success(sourceFiles)):
                state.sourceFiles = sourceFiles
                return .none

            case .sourceFileResponse(.failure):
                return .none

            case .selectButtonTapped:
                return .none

            case .binding:
                return .none
            }
        }
    }
}

public struct SourceFileClientDebugView: View {
    @Bindable public var store: StoreOf<SourceFileClientDebugger>

    public init(store: StoreOf<SourceFileClientDebugger>) {
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
                        VStack(alignment: .leading) {
                            Button("Select") {
                                store.send(.selectButtonTapped(sourceFile))
                            }
                            HStack {
                                Text(sourceFile.content)
                                    .padding(.leading)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .background(.black)
                        }
                        .padding(.leading)
                    }
                }
            }
        }
    }
}
