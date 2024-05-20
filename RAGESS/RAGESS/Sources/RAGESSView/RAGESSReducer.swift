//
//  RAGESSReducer.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

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
        var isShowRootDirectorySelector = false

        public init(projectRootDirectoryPath: String) {
            self.projectRootDirectoryPath = projectRootDirectoryPath
        }
    }

    public enum Action: BindableAction {
        case projectDirectorySelectorButtonTapped
        case projectDirectorySelectorResponse(Result<[URL], Error>)
        case sourceFileResponse(Result<Directory, Error>)
        case sourceFileSelected(SourceFile)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient
    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .projectDirectorySelectorButtonTapped:
                state.isShowRootDirectorySelector = true
                return .none

            case let .projectDirectorySelectorResponse(.success(urls)):
                guard let url = urls.first else {
                    #if DEBUG
                        print("ERROR in \(#file) - \(#line): Cannot find `urls.first`")
                    #endif
                    return .none
                }

                #if DEBUG
                    print("Successfully get project root directory path.")
                    print("╰─\(url.path())")
                #endif

                state.projectRootDirectoryPath = url.path()

                return .run { [projectRootDirectoryPath = state.projectRootDirectoryPath] send in
                    await send(.sourceFileResponse(Result {
                        try await sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: projectRootDirectoryPath,
                            ignoredDirectories: [".build", "DerivedData", ".git"]
                        )
                    }))
                }

            case let .projectDirectorySelectorResponse(.failure(error)):
                #if DEBUG
                    print(error)
                #endif
                return .none

            case let .sourceFileResponse(.success(rootDirectory)):
                print(".sourceFileResponse(.success(rootDirectory))")
                dump(rootDirectory)
                return .none

            case let .sourceFileResponse(.failure(error)):
                #if DEBUG
                    print(error)
                #endif
                return .none

            case let .sourceFileSelected(sourceFile):
                return .none

            case .binding:
                return .none
            }
        }
    }
}
