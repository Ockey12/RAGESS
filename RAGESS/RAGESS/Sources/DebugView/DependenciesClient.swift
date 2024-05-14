//
//  DependenciesClient.swift
//
//  
//  Created by Ockey12 on 2024/05/15
//  
//

import ComposableArchitecture
import DependenciesClient
import SwiftUI
import TypeDeclaration

@Reducer
public struct DependenciesClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var projectRootPath: String
        var declarationObjects: [any DeclarationObject]

        public init(projectRootPath: String, declarationObjects: [any DeclarationObject]) {
            self.projectRootPath = projectRootPath
            self.declarationObjects = declarationObjects
        }
    }

    public enum Action {
        case getDependenciesTapped
        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
    }

    @Dependency(DependenciesClient.self) var dependenciesClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .getDependenciesTapped:
                return .run {
                    [projectRootPath = state.projectRootPath, declarationObjects = state.declarationObjects] send in
                    await send(.extractDependenciesResponse(Result {
                        try await dependenciesClient.extractDependencies(
                            projectRootPath: projectRootPath,
                            declarationObjects: declarationObjects
                        )
                    }))
                }

            case let .extractDependenciesResponse(.success(declarationObjects)):
                return .none

            case let .extractDependenciesResponse(.failure(error)):
                print(error)
                return .none
            }
        }
    }
}

public struct DependenciesClientDebugView: View {
    let store: StoreOf<DependenciesClientDebugger>

    public init(store: StoreOf<DependenciesClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            Text("Project Root Path: \(store.projectRootPath)")
            Button("Extract Dependencies") {
                store.send(.getDependenciesTapped)
            }
        }
    }
}
