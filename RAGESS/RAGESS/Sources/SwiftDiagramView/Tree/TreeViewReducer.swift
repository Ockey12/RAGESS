//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/19
//  
//

import ComposableArchitecture
import DeclarationObjectsClient
import Dependencies
import TypeDeclaration

@Reducer
struct TreeViewReducer {
    @ObservableState
    struct State {
        var rootObject: any TypeDeclaration {
            didSet {
                generateTree(rootObject: rootObject)
            }
        }
        var nodes: IdentifiedArrayOf<NodeReducer.State>
        var allDeclarationObjects: [any DeclarationObject]

        mutating func generateTree(rootObject: any TypeDeclaration) {
            nodes = []
        }
    }

    enum Action {
        case task
        case declarationObjectsClientResponse(Result<[any DeclarationObject], Error>)
        case nodes(IdentifiedActionOf<NodeReducer>)
    }

    @Dependency(DeclarationObjectsClient.self) var declarationObjectsClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.declarationObjectsClientResponse(Result {
                        await declarationObjectsClient.get()
                    }))
                }

            case let .declarationObjectsClientResponse(.success(objects)):
                state.allDeclarationObjects = objects
                return .none

            case let .declarationObjectsClientResponse(.failure(error)):
                print(error)
                return .none

            case .nodes:
                return .none
            }
        }
        .forEach(\.nodes, action: \.nodes) {
            NodeReducer()
        }
    }
}
