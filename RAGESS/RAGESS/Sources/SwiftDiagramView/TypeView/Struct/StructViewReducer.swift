//
//  StructViewReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct StructViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            object.id
        }

        let object: StructObject
        var header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        private let conformedProtocolObjects: [ProtocolObject]
        var topLeadingPoint: CGPoint
        var dragStartPosition: CGPoint
        let frameWidth: CGFloat
        var frameHeight: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight * 2 + bottomPadding

            let conformances: CGFloat
            if conformedProtocolObjects.isEmpty {
                conformances = 0
            } else {
                conformances = connectionHeight + itemHeight * CGFloat(conformedProtocolObjects.count) + bottomPadding
            }

            let initializers: CGFloat
            if object.initializers.isEmpty {
                initializers = 0
            } else {
                initializers = connectionHeight + itemHeight * CGFloat(object.initializers.count) + bottomPadding
            }

            let variables: CGFloat
            if object.variables.isEmpty {
                variables = 0
            } else {
                variables = connectionHeight + itemHeight * CGFloat(object.variables.count) + bottomPadding
            }

            let functions: CGFloat
            if object.functions.isEmpty {
                functions = 0
            } else {
                functions = connectionHeight + itemHeight * CGFloat(object.functions.count) + bottomPadding
            }

            return header
                + conformances
                + initializers
                + variables
                + functions
                + connectionHeight
                + ComponentSizeValues.borderWidth
        }

        public init(
            object: StructObject,
            allDeclarationObjects: [any DeclarationObject],
            topLeadingPoint: CGPoint
        ) {
            self.object = object
            self.topLeadingPoint = topLeadingPoint
            self.dragStartPosition = topLeadingPoint

            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: object,
                allDeclarationObjects: allDeclarationObjects
            )
            self.conformedProtocolObjects = conformedProtocolObjects

            var allAnnotatedDecl = [object.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.variables.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.functions.map { $0.annotatedDecl })

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

            header = HeaderReducer.State(
                object: object,
                topLeadingPoint: topLeadingPoint,
                bodyWidth: bodyWidth
            )

            let borderWidth = ComponentSizeValues.borderWidth
            let connectionHeight = ComponentSizeValues.connectionHeight
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPaddingForLastText = ComponentSizeValues.bottomPaddingForLastText

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
            if !object.initializers.isEmpty {
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                        + connectionHeight
                        + itemHeight * CGFloat(object.initializers.count)
                        + bottomPaddingForLastText
                )
            }

            let variablesTopLeadingPoint = frameBottomLeadingPoint
            if !object.variables.isEmpty {
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                        + connectionHeight
                        + itemHeight * CGFloat(object.variables.count)
                        + bottomPaddingForLastText
                )
            }

            let functionsTopLeadingPoint = frameBottomLeadingPoint

            details = [
                DetailReducer.State(
                    objects: conformedProtocolObjects,
                    kind: .protocolConformance,
                    topLeadingPoint: protocolsFrameTopLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.initializers,
                    kind: .initializers,
                    topLeadingPoint: initializersTopLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.variables,
                    kind: .variables,
                    topLeadingPoint: variablesTopLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.functions,
                    kind: .functions,
                    topLeadingPoint: functionsTopLeadingPoint,
                    frameWidth: bodyWidth
                )
            ]
        }
    }

    @CasePathable
    public enum Action {
        case header(HeaderReducer.Action)
        case dragged(CGSize)
        case dropped(CGSize)
        case details(IdentifiedActionOf<DetailReducer>)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.header, action: \.header) {
            HeaderReducer()
        }
        Reduce { state, action in
            switch action {
            case let .dragged(translation):
                state.topLeadingPoint = CGPoint(
                    x: state.dragStartPosition.x + translation.width,
                    y: state.dragStartPosition.y + translation.height
                )
                return .none

            case let .dropped(translation):
                let droppedPosition = CGPoint(
                    x: state.dragStartPosition.x + translation.width,
                    y: state.dragStartPosition.y + translation.height
                )
                state.topLeadingPoint = droppedPosition
                state.dragStartPosition = droppedPosition
                return .none

            case .header:
                return .none

            case .details:
                return .none
            }
        }
        .forEach(\.details, action: \.details) {
            DetailReducer()
        }
    }
}
