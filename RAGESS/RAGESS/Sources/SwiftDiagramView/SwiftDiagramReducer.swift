//
//  SwiftDiagramReducer.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct SwiftDiagramReducer {
    public init() {}

    @ObservableState
    public struct State {
        var protocols: IdentifiedArrayOf<ProtocolViewReducer.State>
        var structs: IdentifiedArrayOf<StructViewReducer.State>
        var classes: IdentifiedArrayOf<ClassViewReducer.State>
        var enums: IdentifiedArrayOf<EnumViewReducer.State>
        public var frameWidth: CGFloat = 0
        public var frameHeight: CGFloat = 0

        public init(allDeclarationObjects: [any DeclarationObject]) {
            var protocolObjects: [ProtocolObject] = []
            var structObjects: [StructObject] = []
            var classObjects: [ClassObject] = []
            var enumObjects: [EnumObject] = []

            for object in allDeclarationObjects {
                if let protocolObject = object as? ProtocolObject {
                    protocolObjects.append(protocolObject)
                } else if let structObject = object as? StructObject {
                    structObjects.append(structObject)
                } else if let classObject = object as? ClassObject {
                    classObjects.append(classObject)
                } else if let enumObject = object as? EnumObject {
                    enumObjects.append(enumObject)
                }
            }

            protocols = .init(uniqueElements: protocolObjects.map {
                ProtocolViewReducer.State(object: $0, allDeclarationObjects: allDeclarationObjects)
            })
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
        case protocols(IdentifiedActionOf<ProtocolViewReducer>)
        case structs(IdentifiedActionOf<StructViewReducer>)
        case classes(IdentifiedActionOf<ClassViewReducer>)
        case enums(IdentifiedActionOf<EnumViewReducer>)
        case geometry(width: CGFloat, height: CGFloat)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .protocols:
                return .none

            case let .structs(.element(id: structID, action: .header(.nameClicked))):
                let structObject = state.structs[id: structID]!.object
                let dependencies = structObject.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == structObject.id }
                dump(dependencies)
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .structs(.element(id: structID, action: .details(.element(id: _, action: .delegate(.clickedCell(object: clickedObject)))))):
                let dependencies = state.structs[id: structID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }
                dump(dependencies)
                return .none

            case .structs:
                return .none

            case .classes:
                return .none

            case .enums:
                return .none

            case let .geometry(width: width, height: height):
                state.frameWidth = width
                state.frameHeight = height
                return .none
            }
        }
        .forEach(\.protocols, action: \.protocols) {
            ProtocolViewReducer()
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
