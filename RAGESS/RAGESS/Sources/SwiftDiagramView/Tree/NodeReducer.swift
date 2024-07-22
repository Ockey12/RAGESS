//
//  NodeReducer.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct NodeReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: UUID {
            object.id
        }

        let object: GenericTypeObject
//        let treeDepth: Int

        var header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        private var parentProtocolObjects: [ProtocolObject] = []
        private var superClassObject: ClassObject? = nil
        private let conformedProtocolObjects: [ProtocolObject]

        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let topLeadingPoint: CGPoint
        let subtreeTopLeadingPoint: CGPoint

        public init(
            object: GenericTypeObject,
//            treeDepth: Int,
            allDeclarationObjects: [any DeclarationObject],
            topLeadingPoint: CGPoint,
            subtreeTopLeadingPoint: CGPoint
        ) {
            self.object = object
//            self.treeDepth = treeDepth
            self.topLeadingPoint = topLeadingPoint
            self.subtreeTopLeadingPoint = subtreeTopLeadingPoint

            let borderWidth = ComponentSizeValues.borderWidth
            let connectionHeight = ComponentSizeValues.connectionHeight
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPaddingForLastText = ComponentSizeValues.bottomPaddingForLastText
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText

            var hasSuperClass = false
            var numberOfParentProtocols = 0
            var numberOfConformances = 0
            var numberOfInitializers = 0
            var numberOfCases = 0
            var numberOfVariables = 0
            var numberOfFunctions = 0

            switch object {
            case let .struct(structObject):
                let conformedProtocolObjects = extractConformedProtocolObjects(
                    by: structObject,
                    allDeclarationObjects: allDeclarationObjects
                )
                self.conformedProtocolObjects = conformedProtocolObjects

                var allAnnotatedDecl = [structObject.annotatedDecl]
                allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
                numberOfConformances = conformedProtocolObjects.count

                allAnnotatedDecl.append(contentsOf: structObject.initializers.map { $0.annotatedDecl })
                numberOfInitializers = structObject.initializers.count

                allAnnotatedDecl.append(contentsOf: structObject.variables.map { $0.annotatedDecl })
                numberOfVariables = structObject.variables.count

                allAnnotatedDecl.append(contentsOf: structObject.functions.map { $0.annotatedDecl })
                numberOfFunctions = structObject.functions.count

                let bodyWidth = max(
                    calculateMaxTextWidth(allAnnotatedDecl),
                    ComponentSizeValues.bodyMinWidth
                )
                frameWidth = bodyWidth
                    + ComponentSizeValues.arrowTerminalWidth * 2
                    + ComponentSizeValues.borderWidth

                var frameBottomLeadingPoint = CGPoint(
                    x: topLeadingPoint.x,
                    y: topLeadingPoint.y
                        + borderWidth / 2
                        + itemHeight * 2
                        + bottomPaddingForLastText
                )

                let protocolsFrameTopLeadingPoint = frameBottomLeadingPoint
                if !conformedProtocolObjects.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(conformedProtocolObjects.count)
                            + bottomPaddingForLastText
                    )
                }

                let initializersTopLeadingPoint = frameBottomLeadingPoint
                if !structObject.initializers.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(structObject.initializers.count)
                            + bottomPaddingForLastText
                    )
                }

                let variablesTopLeadingPoint = frameBottomLeadingPoint
                if !structObject.variables.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(structObject.variables.count)
                            + bottomPaddingForLastText
                    )
                }

                let functionsTopLeadingPoint = frameBottomLeadingPoint

                header = HeaderReducer.State(
                    object: structObject,
                    topLeadingPoint: topLeadingPoint,
                    bodyWidth: bodyWidth
                )

                details = [
                    DetailReducer.State(
                        objects: conformedProtocolObjects,
                        kind: .protocolConformance,
                        topLeadingPoint: protocolsFrameTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: structObject.initializers,
                        kind: .initializers,
                        topLeadingPoint: initializersTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: structObject.variables,
                        kind: .variables,
                        topLeadingPoint: variablesTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: structObject.functions,
                        kind: .functions,
                        topLeadingPoint: functionsTopLeadingPoint,
                        frameWidth: bodyWidth
                    )
                ]

            case let .class(classObject):
                let superClassObject = extractSuperClassObject(
                    by: classObject,
                    allDeclarationObjects: allDeclarationObjects
                )
                self.superClassObject = superClassObject

                let conformedProtocolObjects = extractConformedProtocolObjects(
                    by: classObject,
                    allDeclarationObjects: allDeclarationObjects
                )
                self.conformedProtocolObjects = conformedProtocolObjects
                numberOfConformances = conformedProtocolObjects.count

                var allAnnotatedDecl = [classObject.annotatedDecl]
                if let superClassObject {
                    allAnnotatedDecl.append(superClassObject.annotatedDecl)
                    hasSuperClass = true
                }
                allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
                numberOfConformances = conformedProtocolObjects.count

                allAnnotatedDecl.append(contentsOf: classObject.initializers.map { $0.annotatedDecl })
                numberOfInitializers = classObject.initializers.count

                allAnnotatedDecl.append(contentsOf: classObject.variables.map { $0.annotatedDecl })
                numberOfVariables = classObject.variables.count

                allAnnotatedDecl.append(contentsOf: classObject.functions.map { $0.annotatedDecl })
                numberOfFunctions = classObject.functions.count

                let bodyWidth = max(
                    calculateMaxTextWidth(allAnnotatedDecl),
                    ComponentSizeValues.bodyMinWidth
                )
                frameWidth = bodyWidth
                    + ComponentSizeValues.arrowTerminalWidth * 2
                    + ComponentSizeValues.borderWidth

                var frameBottomLeadingPoint = CGPoint(
                    x: topLeadingPoint.x,
                    y: topLeadingPoint.y
                        + borderWidth / 2
                        + itemHeight * 2
                        + bottomPaddingForLastText
                )

                var details: [DetailReducer.State] = []

                if let superClassObject {
                    details.append(
                        DetailReducer.State(
                            objects: [superClassObject],
                            kind: .superClass,
                            topLeadingPoint: frameBottomLeadingPoint,
                            frameWidth: bodyWidth
                        )
                    )

                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight
                            + bottomPaddingForLastText
                    )
                }

                let protocolsFrameTopLeadingPoint = frameBottomLeadingPoint
                if !conformedProtocolObjects.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(conformedProtocolObjects.count)
                            + bottomPaddingForLastText
                    )
                }

                let initializersTopLeadingPoint = frameBottomLeadingPoint
                if !classObject.initializers.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(classObject.initializers.count)
                            + bottomPaddingForLastText
                    )
                }

                let variablesTopLeadingPoint = frameBottomLeadingPoint
                if !classObject.variables.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(classObject.variables.count)
                            + bottomPaddingForLastText
                    )
                }

                let functionsTopLeadingPoint = frameBottomLeadingPoint

                details.append(contentsOf: [
                    DetailReducer.State(
                        objects: conformedProtocolObjects,
                        kind: .protocolConformance,
                        topLeadingPoint: protocolsFrameTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: classObject.initializers,
                        kind: .initializers,
                        topLeadingPoint: initializersTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: classObject.variables,
                        kind: .variables,
                        topLeadingPoint: variablesTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: classObject.functions,
                        kind: .functions,
                        topLeadingPoint: functionsTopLeadingPoint,
                        frameWidth: bodyWidth
                    )
                ])

                header = HeaderReducer.State(
                    object: classObject,
                    topLeadingPoint: topLeadingPoint,
                    bodyWidth: bodyWidth
                )
                self.details = .init(uniqueElements: details)

            case let .enum(enumObject):
                let conformedProtocolObjects = extractConformedProtocolObjects(
                    by: enumObject,
                    allDeclarationObjects: allDeclarationObjects
                )
                self.conformedProtocolObjects = conformedProtocolObjects
                numberOfConformances = conformedProtocolObjects.count

                var allAnnotatedDecl = [enumObject.annotatedDecl]
                allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
                numberOfConformances = conformedProtocolObjects.count

                allAnnotatedDecl.append(contentsOf: enumObject.cases.map { $0.annotatedDecl })
                numberOfCases = enumObject.cases.count

                allAnnotatedDecl.append(contentsOf: enumObject.variables.map { $0.annotatedDecl })
                numberOfVariables = enumObject.variables.count

                allAnnotatedDecl.append(contentsOf: enumObject.functions.map { $0.annotatedDecl })
                numberOfFunctions = enumObject.functions.count

                let bodyWidth = max(
                    calculateMaxTextWidth(allAnnotatedDecl),
                    ComponentSizeValues.bodyMinWidth
                )
                frameWidth = bodyWidth
                    + ComponentSizeValues.arrowTerminalWidth * 2
                    + ComponentSizeValues.borderWidth

                var frameBottomLeadingPoint = CGPoint(
                    x: topLeadingPoint.x,
                    y: topLeadingPoint.y
                        + borderWidth / 2
                        + itemHeight * 2
                        + bottomPaddingForLastText
                )

                let protocolsFrameTopLeadingPoint = frameBottomLeadingPoint
                if !conformedProtocolObjects.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(conformedProtocolObjects.count)
                            + bottomPaddingForLastText
                    )
                }

                let initializersTopLeadingPoint = frameBottomLeadingPoint
                if !enumObject.initializers.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(enumObject.initializers.count)
                            + bottomPaddingForLastText
                    )
                }

                let casesFrameTopLeadingPoint = frameBottomLeadingPoint
                if !enumObject.cases.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(enumObject.cases.count)
                            + bottomPaddingForLastText
                    )
                }

                let variablesTopLeadingPoint = frameBottomLeadingPoint
                if !enumObject.variables.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(enumObject.variables.count)
                            + bottomPaddingForLastText
                    )
                }

                let functionsTopLeadingPoint = frameBottomLeadingPoint

                header = HeaderReducer.State(
                    object: enumObject,
                    topLeadingPoint: topLeadingPoint,
                    bodyWidth: bodyWidth
                )

                details = [
                    DetailReducer.State(
                        objects: conformedProtocolObjects,
                        kind: .protocolConformance,
                        topLeadingPoint: protocolsFrameTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: enumObject.initializers,
                        kind: .initializers,
                        topLeadingPoint: initializersTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: enumObject.cases,
                        kind: .case,
                        topLeadingPoint: casesFrameTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: enumObject.variables,
                        kind: .variables,
                        topLeadingPoint: variablesTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: enumObject.functions,
                        kind: .functions,
                        topLeadingPoint: functionsTopLeadingPoint,
                        frameWidth: bodyWidth
                    )
                ]

            case let .protocol(protocolObject):
                let parentProtocolObjects = extractParentProtocolObjects(
                    by: protocolObject,
                    allDeclarationObjects: allDeclarationObjects
                )
                self.parentProtocolObjects = parentProtocolObjects
                conformedProtocolObjects = []

                var allAnnotatedDecl = [protocolObject.annotatedDecl]
                allAnnotatedDecl.append(contentsOf: parentProtocolObjects.map { $0.annotatedDecl })
                numberOfParentProtocols = parentProtocolObjects.count

                allAnnotatedDecl.append(contentsOf: protocolObject.initializers.map { $0.annotatedDecl })
                numberOfInitializers = protocolObject.initializers.count

                allAnnotatedDecl.append(contentsOf: protocolObject.variables.map { $0.annotatedDecl })
                numberOfVariables = protocolObject.variables.count

                allAnnotatedDecl.append(contentsOf: protocolObject.functions.map { $0.annotatedDecl })
                numberOfFunctions = protocolObject.functions.count

                let bodyWidth = max(
                    calculateMaxTextWidth(allAnnotatedDecl),
                    ComponentSizeValues.bodyMinWidth
                )
                frameWidth = bodyWidth
                    + ComponentSizeValues.arrowTerminalWidth * 2
                    + ComponentSizeValues.borderWidth

                var frameBottomLeadingPoint = CGPoint(
                    x: topLeadingPoint.x,
                    y: topLeadingPoint.y
                        + borderWidth / 2
                        + itemHeight * 2
                        + bottomPaddingForLastText
                )

                let protocolsFrameTopLeadingPoint = frameBottomLeadingPoint
                if !parentProtocolObjects.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(parentProtocolObjects.count)
                            + bottomPaddingForLastText
                    )
                }

                let initializersTopLeadingPoint = frameBottomLeadingPoint
                if !protocolObject.initializers.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(protocolObject.initializers.count)
                            + bottomPaddingForLastText
                    )
                }

                let variablesTopLeadingPoint = frameBottomLeadingPoint
                if !protocolObject.variables.isEmpty {
                    frameBottomLeadingPoint = CGPoint(
                        x: frameBottomLeadingPoint.x,
                        y: frameBottomLeadingPoint.y
                            + connectionHeight
                            + itemHeight * CGFloat(protocolObject.variables.count)
                            + bottomPaddingForLastText
                    )
                }

                let functionsTopLeadingPoint = frameBottomLeadingPoint

                details = [
                    DetailReducer.State(
                        objects: parentProtocolObjects,
                        kind: .parentProtocol,
                        topLeadingPoint: protocolsFrameTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: protocolObject.initializers,
                        kind: .initializers,
                        topLeadingPoint: initializersTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: protocolObject.variables,
                        kind: .variables,
                        topLeadingPoint: variablesTopLeadingPoint,
                        frameWidth: bodyWidth
                    ),
                    DetailReducer.State(
                        objects: protocolObject.functions,
                        kind: .functions,
                        topLeadingPoint: functionsTopLeadingPoint,
                        frameWidth: bodyWidth
                    )
                ]

                header = HeaderReducer.State(
                    object: protocolObject,
                    topLeadingPoint: topLeadingPoint,
                    bodyWidth: bodyWidth
                )
            }

            var frameHeight: CGFloat = itemHeight * 2 + bottomPadding
            if hasSuperClass {
                frameHeight += connectionHeight + itemHeight + bottomPadding
            }
            if numberOfParentProtocols > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfParentProtocols) + bottomPadding
            }
            if numberOfConformances > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfConformances) + bottomPadding
            }
            if numberOfInitializers > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfInitializers) + bottomPadding
            }
            if numberOfCases > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfCases) + bottomPadding
            }
            if numberOfVariables > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfVariables) + bottomPadding
            }
            if numberOfFunctions > 0 {
                frameHeight += connectionHeight + itemHeight * CGFloat(numberOfFunctions) + bottomPadding
            }
            frameHeight += connectionHeight + borderWidth

            self.frameHeight = frameHeight
        }
    }

    public enum Action {
        case header(HeaderReducer.Action)
        case details(IdentifiedActionOf<DetailReducer>)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.header, action: \.header) {
            HeaderReducer()
        }
        Reduce { _, _ in
            .none
        }
        .forEach(\.details, action: \.details) {
            DetailReducer()
        }
    }
}
