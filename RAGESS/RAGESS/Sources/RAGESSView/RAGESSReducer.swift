//
//  RAGESSReducer.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import BuildSettingsClient
import ComposableArchitecture
import Dependencies
import Foundation
import MonitorClient
import SourceFileClient
import XcodeObject

@Reducer
public struct RAGESSReducer {
    public init() {}

    @ObservableState
    public struct State {
        var projectRootDirectoryPath: String
        var rootDirectory: Directory?
        var buildSettings: [String: String] = [:]
        var loadingTaskKindBuffer: [LoadingTaskKind] = []

        public init(projectRootDirectoryPath: String) {
            self.projectRootDirectoryPath = projectRootDirectoryPath
        }
    }

    public enum Action: BindableAction {
        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case sourceFileResponse(Result<Directory, Error>)
        case sourceFileSelected(SourceFile)
        case buildSettingsResponse(Result<[String: String], Error>)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient
    @Dependency(BuildSettingsClient.self) var buildSettingsClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .projectDirectorySelectorResponse(.success(urls)):
                guard let url = urls.first else {
                        print("ERROR in \(#file) - \(#line): Cannot find `urls.first`")
                    return .none
                }

                #if DEBUG
                    print("Successfully get project root directory path.")
                    print("╰─\(url.path())")
                #endif

                state.projectRootDirectoryPath = url.path()
                state.loadingTaskKindBuffer.append(.sourceFiles)

                return .run { [projectRootDirectoryPath = state.projectRootDirectoryPath] send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: projectRootDirectoryPath,
                            ignoredDirectories: [".build", "DerivedData", ".git"]
                        )
                    }))
                }

            case let .projectDirectorySelectorResponse(.failure(error)):
                    print(error)
                return .none

            case let .sourceFileResponse(.success(rootDirectory)):
                #if DEBUG
                print(".sourceFileResponse(.success(rootDirectory))")
                dump(rootDirectory)
                #endif

                state.rootDirectory = rootDirectory
                state.loadingTaskKindBuffer.removeFirst()

                guard !rootDirectory.allXcodeprojPathsUnderDirectory.isEmpty else {
                    print("ERROR in \(#file) - \(#line): Cannot find `**.xcodeproj`")
                    return .none
                }

                state.loadingTaskKindBuffer.append(.buildSettings)

                return .run { send in
                    await send(.buildSettingsResponse(Result {
                        try await buildSettingsClient.getSettings(
                            xcodeprojPath: rootDirectory.allXcodeprojPathsUnderDirectory[0]
                        )
                    }))
                }

            case let .sourceFileResponse(.failure(error)):
                    print(error)
                return .none

            case let .sourceFileSelected(sourceFile):
                return .none

            case let .buildSettingsResponse(.success(buildSettings)):
                state.buildSettings = buildSettings
                state.loadingTaskKindBuffer.removeFirst()

                #if DEBUG
                    print("Successfully get buildsettings.")
                    dump(buildSettings)
                #endif
                return .none

            case let .buildSettingsResponse(.failure(error)):
                print(error)
                return .none

            case .binding:
                return .none
            }
        }
    }
}
