//
//  SourceFileClient.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import BuildSettingsClient
import ComposableArchitecture
import SourceFileClient
import SwiftUI
import XcodeObject

@Reducer
public struct SourceFileClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var rootPath: String
        var directory: Directory
        var buildSettings: [String: String]
        var isLoading: Bool = false

        public init(
            xcodeprojPathString: String,
            directory: Directory,
            buildSettings: [String: String]
        ) {
            self.rootPath = xcodeprojPathString
            self.directory = directory
            self.buildSettings = buildSettings
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case sourceFileResponse(Result<Directory, Error>)
        case buildSettingsResponse(Result<[String: String], Error>)
        case selectButtonTapped(SourceFile)
        case binding(BindingAction<State>)
    }

    @Dependency(BuildSettingsClient.self) var buildSettingsClient
    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .getSourceFilesButtonTapped:
                state.isLoading = true
                return .run { [rootPath = state.rootPath] send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: rootPath,
                            ignoredDirectories: [".build", "DerivedData"]
                        )
                    }))
                }

            case let .sourceFileResponse(.success(directory)):
                state.directory = directory
                return .run { [paths = state.directory.allXcodeprojPathsUnderDirectory] send in
                    for path in paths {
                        await send(.buildSettingsResponse(Result {
                            try await buildSettingsClient.getSettings(xcodeprojPath: path)
                        }))
                    }
                }

            case .sourceFileResponse(.failure):
                state.isLoading = false
                return .none

            case let .buildSettingsResponse(.success(buildSettings)):
                state.isLoading = false
                state.buildSettings = buildSettings
                dump(state.buildSettings)
                return .none

            case .buildSettingsResponse(.failure):
                state.isLoading = false
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
        ZStack {
            VStack {
                Form {
                    TextField("Project root path", text: $store.rootPath)
                    Button("Get Source Files") {
                        store.send(.getSourceFilesButtonTapped)
                    }
                }

                ScrollView {
                    DirectoryCell(directory: store.directory)
                }
            }

            if store.isLoading {
                ProgressView()
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
