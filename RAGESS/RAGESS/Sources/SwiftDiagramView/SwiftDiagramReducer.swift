//
//  SwiftDiagramReducer.swift
//
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import ComposableArchitecture
import TypeDeclaration

@Reducer
public struct SwiftDiagramReducer {
    public init() {}

    @ObservableState
    public struct State {
        var structs: IdentifiedArrayOf<StructViewReducer.State>

        public init(allDeclarationObjects: [any DeclarationObject]) {
            var structObjects: [StructObject] = []

            for object in allDeclarationObjects {
                if let structObject = object as? StructObject {
                    structObjects.append(structObject)
                }
            }

            structs = .init(uniqueElements: structObjects.map {
                StructViewReducer.State(object: $0, allDeclarationObjects: allDeclarationObjects)
            })
        }
    }

    public enum Action {
        case structs(IdentifiedActionOf<StructViewReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
        .forEach(\.structs, action: \.structs) {
            StructViewReducer()
        }
    }
}
