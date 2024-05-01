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
        var directory: Directory?
        var buildSettings: [String: String]
        var isLoading: Bool = false
        var selectedFile: SourceFile? = nil

        public init(
            xcodeprojPathString: String,
            directory: Directory? = nil,
            buildSettings: [String: String]
        ) {
            rootPath = xcodeprojPathString
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
                            ignoredDirectories: [".build", "DerivedData", ".git"]
                        )
                    }))
                }

            case let .sourceFileResponse(.success(directory)):
                state.directory = directory
                let paths = directory.allXcodeprojPathsUnderDirectory
                return .run { send in
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

            case let .selectButtonTapped(file):
                state.selectedFile = file
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

                HStack {
                    ScrollView {
                        if let directory = store.directory {
                            FileTreeView(store: store, directory: directory)
                        }
                    }
                    .frame(width: 500)

                    if let file = store.selectedFile {
                        VStack {
                            HStack {
                                Text(file.path)
                                Spacer()
                            }
                            ScrollView {
                                HStack {
                                    Text(file.content)
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .background(.black)
                            }
                            Spacer()
                        }
                    } else {
                        Spacer()
                    }
                }
            }
        }

        if store.isLoading {
            ProgressView()
        }
    }
}

struct FileTreeView: View {
    @Bindable var store: StoreOf<SourceFileClientDebugger>
    let directory: Directory

    init(store: StoreOf<SourceFileClientDebugger>, directory: Directory) {
        self.store = store
        self.directory = directory
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if directory.files.isEmpty,
                   directory.subDirectories.isEmpty {
                    Image(systemName: "folder")
                } else {
                    Image(systemName: "folder.fill")
                }
                Text(directory.name)
                Spacer()
            }
            .frame(height: 20)
            VStack(spacing: 0) {
                ForEach(directory.files) { file in
                    HStack {
                        Button(
                            action: {
                                store.send(.selectButtonTapped(file))
                            },
                            label: {
                                HStack {
                                    Image(systemName: "swift")
                                        .foregroundStyle(.orange)
                                    Text(file.name)
                                }
                            }
                        )
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .frame(height: 20)
                }
                ForEach(directory.subDirectories) { subDirectory in
                    FileTreeView(store: store, directory: subDirectory)
                }
            }
            .padding(.leading, 24)
        }
    }
}

