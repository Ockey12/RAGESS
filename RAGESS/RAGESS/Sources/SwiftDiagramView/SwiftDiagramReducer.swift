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
        public var frameWidth: CGFloat = 1
        public var frameHeight: CGFloat = 1

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

            var protocolsRowTrailingX: CGFloat = 0
            let protocols = IdentifiedArray(uniqueElements: protocolObjects.map { object in
                let state = ProtocolViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                protocolsRowTrailingX += frameWidth
                protocolsRowTrailingX += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.protocols = protocols

            topLeadingPoint.x = 0
            if !protocols.isEmpty {
                topLeadingPoint.y += protocols.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            var structsRowTrailingX: CGFloat = 0
            let structs = IdentifiedArray(uniqueElements: structObjects.map { object in
                let state = StructViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                structsRowTrailingX += frameWidth
                structsRowTrailingX += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.structs = structs

            topLeadingPoint.x = 0
            if !structs.isEmpty {
                topLeadingPoint.y += structs.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            var classesRowTrailingX: CGFloat = 0
            let classes = IdentifiedArray(uniqueElements: classObjects.map { object in
                let state = ClassViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                classesRowTrailingX += frameWidth
                classesRowTrailingX += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.classes = classes

            topLeadingPoint.x = 0
            if !classes.isEmpty {
                topLeadingPoint.y += classes.map { $0.frameHeight }.max()!
            }
            topLeadingPoint.y += ComponentSizeValues.typeRowsSpacing

            var enumsRowTrailingX: CGFloat = 0
            let enums = IdentifiedArray(uniqueElements: enumObjects.map { object in
                let state = EnumViewReducer.State(object: object, allDeclarationObjects: allDeclarationObjects, topLeadingPoint: topLeadingPoint)
                let frameWidth = state.frameWidth
                topLeadingPoint.x += frameWidth
                topLeadingPoint.x += ComponentSizeValues.typeRowsSpacing
                enumsRowTrailingX += frameWidth
                enumsRowTrailingX += ComponentSizeValues.typeRowsSpacing
                return state
            })
            self.enums = enums

            self.frameWidth = max(
                max(
                    protocolsRowTrailingX - ComponentSizeValues.typeRowsSpacing,
                    structsRowTrailingX - ComponentSizeValues.typeRowsSpacing
                ),
                max(
                    classesRowTrailingX - ComponentSizeValues.typeRowsSpacing,
                    enumsRowTrailingX - ComponentSizeValues.typeRowsSpacing
                )
            )

            self.frameHeight = {
                if enums.isEmpty {
                    return topLeadingPoint.y
                } else {
                    return topLeadingPoint.y + enums.map { $0.frameHeight }.max()!
                }
            }()

            self.allDeclarationObjects = allDeclarationObjects
        }
    }

    public enum Action {
        case protocols(IdentifiedActionOf<ProtocolViewReducer>)
        case structs(IdentifiedActionOf<StructViewReducer>)
        case classes(IdentifiedActionOf<ClassViewReducer>)
        case enums(IdentifiedActionOf<EnumViewReducer>)
        case arrows(IdentifiedActionOf<ArrowViewReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .protocols(.element(id: protocolID, action: .header(.delegate(.clicked(
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            ))))):
                let dependencies = state.protocols[id: protocolID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == protocolID }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: protocolID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .protocols(.element(id: protocolID, action: .details(.element(id: _, action: .delegate(.clickedCell(
                object: clickedObject,
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            )))))):
                let dependencies = state.protocols[id: protocolID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: protocolID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            case .protocols:
                return .none

            case let .structs(.element(id: structID, action: .header(.delegate(.clicked(
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            ))))):
                let dependencies = state.structs[id: structID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == structID }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: structID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .structs(.element(id: structID, action: .details(.element(id: _, action: .delegate(.clickedCell(
                object: clickedObject,
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            )))))):
                let dependencies = state.structs[id: structID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: structID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            case let .structs(.element(id: structID, action: .dragged(translation))):
                for arrow in state.arrows {
                    if arrow.startPointRootObjectID == structID {
                        state.arrows[id: arrow.id]!.leadingStartPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragLeadingStartPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragLeadingStartPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.trailingStartPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragTrailingStartPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragTrailingStartPoint.y + translation.height
                        )
                    }
                    if arrow.endPointRootObjectID == structID {
                        state.arrows[id: arrow.id]!.leadingEndPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragLeadingEndPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragLeadingEndPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.trailingEndPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragTrailingEndPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragTrailingEndPoint.y + translation.height
                        )
                    }
//                    if arrow.startPointRootObjectID == structID {
//                        state.arrows[id: arrow.id]!.startPoint = CGPoint(
//                            x: state.arrows[id: arrow.id]!.beforeDragStartPoint.x + translation.width,
//                            y: state.arrows[id: arrow.id]!.beforeDragStartPoint.y + translation.height
//                        )
//                    }
//                    if arrow.endPointRootObjectID == structID {
//                        state.arrows[id: arrow.id]!.endPoint = CGPoint(
//                            x: state.arrows[id: arrow.id]!.beforeDragEndPoint.x + translation.width,
//                            y: state.arrows[id: arrow.id]!.beforeDragEndPoint.y + translation.height
//                        )
//                    }
                }
                return .none

            case let .structs(.element(id: structID, action: .dropped(translation))):
                for arrow in state.arrows {
                    if arrow.startPointRootObjectID == structID {
                        let leadingStartPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragLeadingStartPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragLeadingStartPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.leadingStartPoint = leadingStartPoint
                        state.arrows[id: arrow.id]!.beforeDragLeadingStartPoint = leadingStartPoint

                        let trailingStartPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragTrailingStartPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragTrailingStartPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.trailingStartPoint = trailingStartPoint
                        state.arrows[id: arrow.id]!.beforeDragTrailingStartPoint = trailingStartPoint
                    }
                    if arrow.endPointRootObjectID == structID {
                        let leadingEndPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragLeadingEndPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragLeadingEndPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.leadingEndPoint = leadingEndPoint
                        state.arrows[id: arrow.id]!.beforeDragLeadingEndPoint = leadingEndPoint

                        let trailingEndPoint = CGPoint(
                            x: state.arrows[id: arrow.id]!.beforeDragTrailingEndPoint.x + translation.width,
                            y: state.arrows[id: arrow.id]!.beforeDragTrailingEndPoint.y + translation.height
                        )
                        state.arrows[id: arrow.id]!.trailingEndPoint = trailingEndPoint
                        state.arrows[id: arrow.id]!.beforeDragTrailingEndPoint = trailingEndPoint
                    }
//                    if arrow.startPointRootObjectID == structID {
//                        let startPoint = CGPoint(
//                            x: state.arrows[id: arrow.id]!.beforeDragStartPoint.x + translation.width,
//                            y: state.arrows[id: arrow.id]!.beforeDragStartPoint.y + translation.height
//                        )
//                        state.arrows[id: arrow.id]!.startPoint = startPoint
//                        state.arrows[id: arrow.id]!.beforeDragStartPoint = startPoint
//                    }
//                    if arrow.endPointRootObjectID == structID {
//                        let endPoint = CGPoint(
//                            x: state.arrows[id: arrow.id]!.beforeDragEndPoint.x + translation.width,
//                            y: state.arrows[id: arrow.id]!.beforeDragEndPoint.y + translation.height
//                        )
//                        state.arrows[id: arrow.id]!.endPoint = endPoint
//                        state.arrows[id: arrow.id]!.beforeDragEndPoint = endPoint
//                    }
                }
                return .none

            case .structs:
                return .none

            case let .classes(.element(id: classID, action: .header(.delegate(.clicked(
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            ))))):
                let dependencies = state.classes[id: classID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == classID }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: classID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .classes(.element(id: classID, action: .details(.element(id: _, action: .delegate(.clickedCell(
                object: clickedObject,
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            )))))):
                let dependencies = state.classes[id: classID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: classID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            case .classes:
                return .none

            case let .enums(.element(id: enumID, action: .header(.delegate(.clicked(
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            ))))):
                let dependencies = state.enums[id: enumID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == enumID }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: enumID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            // FIXME: Apply the Delegate pattern.
            case let .enums(.element(id: enumID, action: .details(.element(id: _, action: .delegate(.clickedCell(
                object: clickedObject,
                leadingArrowTerminalPoint: leadingStartPoint,
                trailingArrowTerminalPoint: trailingStartPoint
            )))))):
                let dependencies = state.enums[id: enumID]!.object.objectsThatCallThisObject.filter { $0.definitionObject.leafObjectID == clickedObject.id }

                #if DEBUG
                    dump(dependencies)
                #endif

                state.arrows = .init(
                    uniqueElements: generateArrowStates(
                        state: state,
                        startPointRootObjectID: enumID,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        dependencies: dependencies
                    )
                )
                return .none

            case .enums:
                return .none

            case .arrows:
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

extension SwiftDiagramReducer {
    func generateArrowStates(
        state: State,
        startPointRootObjectID: UUID,
        leadingStartPoint: CGPoint,
        trailingStartPoint: CGPoint,
        dependencies: [DependencyObject]
    ) -> [ArrowViewReducer.State] {
        var arrowStates: [ArrowViewReducer.State] = []

        for dependency in dependencies {
            let callerLeafID: UUID
            switch dependency.kind {
            case .protocolInheritance:
                callerLeafID = startPointRootObjectID
            case .classInheritance:
                callerLeafID = startPointRootObjectID
            case .protocolConformance:
                callerLeafID = startPointRootObjectID
            case .declarationReference:
                callerLeafID = dependency.callerObject.leafObjectID
            case .identifierType:
                callerLeafID = dependency.callerObject.leafObjectID
            }

            let endPointsTuple: (CGPoint, CGPoint)? = {
                switch dependency.callerObject.keyPath {
                case .protocol:
                    for protocolState in state.protocols
                        where protocolState.object.id == dependency.callerObject.rootObjectID {
                        for detail in protocolState.details {
                            for textState in detail.texts {
                                if textState.id == callerLeafID
                                    || textState.object.descendantsID.contains(callerLeafID) {
                                    if startPointRootObjectID != protocolState.id,
                                       let childDependencies = state.protocols[id: protocolState.id]?.object.objectsThatCallThisObject.filter({
                                           $0.definitionObject.leafObjectID == callerLeafID
                                       }) {
                                        let childArrowStates = generateArrowStates(
                                            state: state,
                                            startPointRootObjectID: protocolState.id,
                                            leadingStartPoint: textState.leadingArrowTerminalPoint,
                                            trailingStartPoint: textState.trailingArrowTerminalPoint,
                                            dependencies: childDependencies
                                        )
                                        arrowStates.append(contentsOf: childArrowStates)
                                    }
                                    return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                }
                            }
                        }
                    }
                    return nil

                case .struct:
                    for structState in state.structs
                        where structState.object.id == dependency.callerObject.rootObjectID {
                        for detail in structState.details {
                            for textState in detail.texts {
                                if textState.id == callerLeafID
                                    || textState.object.descendantsID.contains(callerLeafID) {
                                    if startPointRootObjectID != structState.id,
                                       let childDependencies = state.structs[id: structState.id]?.object.objectsThatCallThisObject.filter({
                                           $0.definitionObject.leafObjectID == callerLeafID
                                       }) {
                                        let childArrowStates = generateArrowStates(
                                            state: state,
                                            startPointRootObjectID: structState.id,
                                            leadingStartPoint: textState.leadingArrowTerminalPoint,
                                            trailingStartPoint: textState.trailingArrowTerminalPoint,
                                            dependencies: childDependencies
                                        )
                                        arrowStates.append(contentsOf: childArrowStates)
                                    }
                                    return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                }
                            }
                        }
                    }
                    return nil

                case .class:
                    for classState in state.classes
                        where classState.object.id == dependency.callerObject.rootObjectID {
                        for detail in classState.details {
                            for textState in detail.texts {
                                if textState.id == callerLeafID
                                    || textState.object.descendantsID.contains(callerLeafID) {
                                    if startPointRootObjectID != classState.id,
                                       let childDependencies = state.classes[id: classState.id]?.object.objectsThatCallThisObject.filter({
                                           $0.definitionObject.leafObjectID == callerLeafID
                                       }) {
                                        let childArrowStates = generateArrowStates(
                                            state: state,
                                            startPointRootObjectID: classState.id,
                                            leadingStartPoint: textState.leadingArrowTerminalPoint,
                                            trailingStartPoint: textState.trailingArrowTerminalPoint,
                                            dependencies: childDependencies
                                        )
                                        arrowStates.append(contentsOf: childArrowStates)
                                    }
                                    return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                }
                            }
                        }
                    }
                    return nil

                case .enum:
                    for enumState in state.enums
                        where enumState.object.id == dependency.callerObject.rootObjectID {
                        for detail in enumState.details {
                            for textState in detail.texts {
                                if textState.id == callerLeafID
                                    || textState.object.descendantsID.contains(callerLeafID) {
                                    if startPointRootObjectID != enumState.id,
                                       let childDependencies = state.enums[id: enumState.id]?.object.objectsThatCallThisObject.filter({
                                           $0.definitionObject.leafObjectID == callerLeafID
                                       }) {
                                        let childArrowStates = generateArrowStates(
                                            state: state,
                                            startPointRootObjectID: enumState.id,
                                            leadingStartPoint: textState.leadingArrowTerminalPoint,
                                            trailingStartPoint: textState.trailingArrowTerminalPoint,
                                            dependencies: childDependencies
                                        )
                                        arrowStates.append(contentsOf: childArrowStates)
                                    }
                                    return (textState.leadingArrowTerminalPoint, textState.trailingArrowTerminalPoint)
                                }
                            }
                        }
                    }
                    return nil

                case .variable:
                    return nil

                case .function:
                    return nil
                }
            }()

            guard let endPointsTuple else {
                continue
            }
            let (leadingEndPoint, trailingEndPoint) = endPointsTuple
//            let combinations = [
//                (leadingStartPoint, leadingEndPoint),
//                (leadingStartPoint, trailingEndPoint),
//                (trailingStartPoint, leadingEndPoint),
//                (trailingStartPoint, trailingEndPoint)
//            ]
//
//            var minDistance = CGFloat.infinity
//            var startPoint = CGPoint()
//            var endPoint = CGPoint()
//            for (start, end) in combinations {
//                let distance = hypot(start.x - end.x, start.y - end.y)
//                if distance < minDistance {
//                    startPoint = start
//                    endPoint = end
//                    minDistance = distance
//                }
//            }

            arrowStates.append(ArrowViewReducer.State(
                startPointRootObjectID: startPointRootObjectID,
                endPointRootObjectID: dependency.callerObject.rootObjectID,
                leadingStartPoint: leadingStartPoint,
                trailingStartPoint: trailingStartPoint,
                leadingEndPoint: leadingEndPoint,
                trailingEndPoint: trailingEndPoint
            ))
        } // for

        return arrowStates
    }
}
