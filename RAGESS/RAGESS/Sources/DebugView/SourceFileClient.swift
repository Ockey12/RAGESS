//
//  SourceFileClient.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import DerivedDataPathClient
import SourceFileClient
import SwiftUI

@Reducer
public struct SourceFileClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var xcodeprojPathString: String
        var sourceFiles: IdentifiedArrayOf<SourceFile>

        public init(
            xcodeprojPathString: String,
            sourceFiles: IdentifiedArrayOf<SourceFile>
        ) {
            self.xcodeprojPathString = xcodeprojPathString
            self.sourceFiles = sourceFiles
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case derivedDataPathResponse(Result<String, Error>)
        case sourceFileResponse(Result<IdentifiedArrayOf<SourceFile>, Error>)
        case selectButtonTapped(SourceFile)
        case binding(BindingAction<State>)
    }

    @Dependency(DerivedDataPathClient.self) var derivedDataPathClient
    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .getSourceFilesButtonTapped:
                return .run { [xcodeprojPathString = state.xcodeprojPathString] send in
                    await send(.derivedDataPathResponse(Result {
                        try await derivedDataPathClient.getPath(xcodeprojPath: xcodeprojPathString)
                    }))
                }

            case let .derivedDataPathResponse(.success(derivedDataPath)):
                print(".derivedDataPathResponse(.success(derivedDataPath)): \(derivedDataPath)")
                let projectRootPath = NSString(string: state.xcodeprojPathString).deletingLastPathComponent
                return .run { send in
                    await send(.sourceFileResponse(Result {
                        try await IdentifiedArray(
                            uniqueElements: sourceFileClient.getSourceFiles(
                                rootDirectoryPath: projectRootPath,
                                ignoredDirectories: [".build", "DerivedData"]
                            )
                        )
                    }))
                }

            case .derivedDataPathResponse(.failure):
                return .none

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
                TextField("Project root path", text: $store.xcodeprojPathString)
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
