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
        var allDeclarationObjects: [any DeclarationObject] = []
        var protocols: IdentifiedArrayOf<ProtocolViewReducer.State>
        var structs: IdentifiedArrayOf<StructViewReducer.State>
        var classes: IdentifiedArrayOf<ClassViewReducer.State>
        var enums: IdentifiedArrayOf<EnumViewReducer.State>
        var arrows: IdentifiedArrayOf<ArrowViewReducer.State> = []
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

            var topLeadingPoint = CGPoint(x: 0, y: 0)

            let protocols = IdentifiedArray(uniqueElements: protocolObjects.map { object in
                let state = ProtocolViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.protocols = protocols

            topLeadingPoint.x = 0
            if !protocols.isEmpty {
                topLeadingPoint.y += protocols.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            let structs = IdentifiedArray(uniqueElements: structObjects.map { object in
                let state = StructViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.structs = structs

            topLeadingPoint.x = 0
            if !structs.isEmpty {
                topLeadingPoint.y += structs.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            let classes = IdentifiedArray(uniqueElements: classObjects.map { object in
                let state = ClassViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.classes = classes

            topLeadingPoint.x = 0
            if !classes.isEmpty {
                topLeadingPoint.y += classes.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            enums = .init(uniqueElements: enumObjects.map { object in
                let state = EnumViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                return state
            })

            self.allDeclarationObjects = allDeclarationObjects
        }
    }

    public enum Action {
        case protocols(IdentifiedActionOf<ProtocolViewReducer>)
        case structs(IdentifiedActionOf<StructViewReducer>)
        case classes(IdentifiedActionOf<ClassViewReducer>)
        case enums(IdentifiedActionOf<EnumViewReducer>)
        case arrows(IdentifiedActionOf<ArrowViewReducer>)
        case geometry(width: CGFloat, height: CGFloat)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .protocols(.element(id: protocolID, action: .header(.text(.clicked)))):
                let protocolObject = state.protocols[id: protocolID]!.object
                let dependencies = protocolObject.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == protocolObject.id }
                dump(dependencies)
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .protocols(.element(id: protocolID, action: .details(.element(id: _, action: .delegate(.clickedCell(object: clickedObject, leadingArrowTerminalPoint: leadingArrowTerminalPoint, trailingArrowTerminalPoint: trailingArrowTerminalPoint)))))):
                let dependencies = state.protocols[id: protocolID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }
                dump(dependencies)
                return .none

            case .protocols:
                return .none

            case let .structs(.element(id: structID, action: .header(.text(.clicked)))):
                let structObject = state.structs[id: structID]!.object
                let dependencies = structObject.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == structObject.id }
                dump(dependencies)
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .structs(.element(id: structID, action: .details(.element(id: _, action: .delegate(.clickedCell(object: clickedObject, leadingArrowTerminalPoint: leadingStartPoint, trailingArrowTerminalPoint: trailingStartPoint)))))):
                let dependencies = state.structs[id: structID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }
                dump(dependencies)
                var arrowStates: [ArrowViewReducer.State] = []
                for dependency in dependencies {
                    let callerLeafID = dependency.callerObject.leafObjectID
                    let endPointsTuple: (CGPoint, CGPoint)? = {
                        switch dependency.callerObject.keyPath {
                        case .protocol(let partialKeyPath):
                            for protocolState in state.structs {
                                for detail in protocolState.details {
                                    for textState in detail.texts {
                                        if textState.id == callerLeafID {
                                            return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                        }
                                    }
                                }
                            }
                            return nil

                        case .struct(let partialKeyPath):
                            for structState in state.structs {
                                for detail in structState.details {
                                    for textState in detail.texts {
                                        if textState.id == callerLeafID {
                                            return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                        }
                                    }
                                }
                            }
                            return nil

                        case .class(let partialKeyPath):
                            for classState in state.structs {
                                for detail in classState.details {
                                    for textState in detail.texts {
                                        if textState.id == callerLeafID {
                                            return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                        }
                                    }
                                }
                            }
                            return nil

                        case .enum(let partialKeyPath):
                            for enumState in state.structs {
                                for detail in enumState.details {
                                    for textState in detail.texts {
                                        if textState.id == callerLeafID {
                                            return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                        }
                                    }
                                }
                            }
                            return nil

                        case .variable(let partialKeyPath):
                            return nil

                        case .function(let partialKeyPath):
                            return nil
                        }
                    }()

                    guard let endPointsTuple else {
                        continue
                    }
                    let (leadingEndPoint, trailingEndPoint) = endPointsTuple
                    let combinations = [
                        (leadingStartPoint, leadingEndPoint),
                        (leadingStartPoint, trailingEndPoint),
                        (trailingStartPoint, leadingEndPoint),
                        (trailingStartPoint, trailingEndPoint)
                    ]

                    var minDistance = CGFloat.infinity
                    var startPoint = CGPoint()
                    var endPoint = CGPoint()
                    for (start, end) in combinations {
                        let distance = hypot(start.x - end.x, start.y - end.y)
                        if distance < minDistance {
                            startPoint = start
                            endPoint = end
                            minDistance = distance
                        }
                    }

                    arrowStates.append(ArrowViewReducer.State(
                        startPointRootObjectID: structID,
                        endPointRootObjectID: dependency.callerObject.rootObjectID,
                        startPoint: startPoint,
                        endPoint: endPoint))
                }
                state.arrows = .init(uniqueElements: arrowStates)
                return .none

            case .structs:
                return .none

            case let .classes(.element(id: classID, action: .header(.text(.clicked)))):
                let classObject = state.classes[id: classID]!.object
                let dependencies = classObject.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == classObject.id }
                dump(dependencies)
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .classes(.element(id: classID, action: .details(.element(id: _, action: .delegate(.clickedCell(object: clickedObject, leadingArrowTerminalPoint: leadingArrowTerminalPoint, trailingArrowTerminalPoint: trailingArrowTerminalPoint)))))):
                let dependencies = state.classes[id: classID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }
                dump(dependencies)
                return .none

            case .classes:
                return .none

            case let .enums(.element(id: enumID, action: .header(.text(.clicked)))):
                let enumObject = state.enums[id: enumID]!.object
                let dependencies = enumObject.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == enumObject.id }
                dump(dependencies)
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .enums(.element(id: enumID, action: .details(.element(id: _, action: .delegate(.clickedCell(object: clickedObject, leadingArrowTerminalPoint: leadingArrowTerminalPoint, trailingArrowTerminalPoint: trailingArrowTerminalPoint)))))):
                let dependencies = state.enums[id: enumID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }
                dump(dependencies)
                return .none

            case .enums:
                return .none

            case .arrows:
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
        .forEach(\.arrows, action: \.arrows) {
            ArrowViewReducer()
        }
    }
}
