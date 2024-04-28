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
import XcodeObject

@Reducer
public struct SourceFileClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var xcodeprojPathString: String
        var directory: Directory

        public init(
            xcodeprojPathString: String,
            directory: Directory
        ) {
            self.xcodeprojPathString = xcodeprojPathString
            self.directory = directory
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case derivedDataPathResponse(Result<String, Error>)
        case sourceFileResponse(Result<Directory, Error>)
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
                let projectRootPath = NSString(string: state.xcodeprojPathString).deletingLastPathComponent
                print(projectRootPath)
                return .run { send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: projectRootPath,
                            ignoredDirectories: [".build", "DerivedData"]
                        )
                    }))
                }

            case .derivedDataPathResponse(.failure):
                return .none

            case let .sourceFileResponse(.success(directory)):
                state.directory = directory
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
                DirectoryCell(directory: store.directory)
            }
        }
    }
}

struct DirectoryCell: View {
    let directory: Directory

    var body: some View {
        DisclosureGroup(
            content: {
                ForEach(directory.files) { file in
                    HStack {
                        Image(systemName: "swift")
                        Text(file.name)
                        Spacer()
                    }
                    .padding(.leading, 30)
                }
                ForEach(directory.subDirectories) { subDirectory in
                    Self(directory: subDirectory)
                        .padding(.leading, 30)
                }
            },
            label: {
                HStack {
                    Image(systemName: "folder.fill")
                    Text(directory.name)
                    Spacer()
                }
            }
        )
    }
}
