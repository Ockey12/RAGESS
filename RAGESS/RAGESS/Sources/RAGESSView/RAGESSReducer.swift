//
//  RAGESSReducer.swift
//  
//  
//  Created by Ockey12 on 2024/05/21
//  
//

import ComposableArchitecture
import Foundation

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
        case binding(BindingAction<State>)
    }

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
                return .none

            case let .projectDirectorySelectorResponse(.failure(error)):
                #if DEBUG
                    print(error)
                #endif
                return .none

            case .binding:
                return .none
            }
        }
    }
}
