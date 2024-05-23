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
        var classes: IdentifiedArrayOf<ClassViewReducer.State>
        var enums: IdentifiedArrayOf<EnumViewReducer.State>

        public init(allDeclarationObjects: [any DeclarationObject]) {
            var structObjects: [StructObject] = []
            var classObjects: [ClassObject] = []
            var enumObjects: [EnumObject] = []

            for object in allDeclarationObjects {
                if let structObject = object as? StructObject {
                    structObjects.append(structObject)
                } else if let classObject = object as? ClassObject {
                    classObjects.append(classObject)
                } else if let enumObject = object as? EnumObject {
                    enumObjects.append(enumObject)
                }
            }

            structs = .init(uniqueElements: structObjects.map {
                StructViewReducer.State(object: $0, allDeclarationObjects: allDeclarationObjects)
            })

            classes = .init(uniqueElements: classObjects.map {
                ClassViewReducer.State(object: $0, allDeclarationObjects: allDeclarationObjects)
            })

            enums = .init(uniqueElements: enumObjects.map {
                EnumViewReducer.State(object: $0, allDeclarationObjects: allDeclarationObjects)
            })
        }
    }

    public enum Action {
        case structs(IdentifiedActionOf<StructViewReducer>)
        case classes(IdentifiedActionOf<ClassViewReducer>)
        case enums(IdentifiedActionOf<EnumViewReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
        .forEach(\.structs, action: \.structs) {
            StructViewReducer()
        }
        .forEach(\.classes, action: \.classes) {
            ClassViewReducer()
        }
        .forEach(\.enums, action: \.enums) {
            EnumViewReducer()
        }
    }
}
