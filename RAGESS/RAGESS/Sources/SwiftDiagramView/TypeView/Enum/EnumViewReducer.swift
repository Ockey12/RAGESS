//
//  EnumViewReducer.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct EnumViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            object.id
        }

        let object: EnumObject
        var header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        var topLeadingPoint: CGPoint
        let frameWidth: CGFloat
        private let conformedProtocolObjects: [ProtocolObject]
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

            let cases: CGFloat
            if object.cases.isEmpty {
                cases = 0
            } else {
                cases = connectionHeight + itemHeight * CGFloat(object.cases.count) + bottomPadding
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
                + cases
                + variables
                + functions
                + connectionHeight
                + ComponentSizeValues.borderWidth
        }

        public init(object: EnumObject, allDeclarationObjects: [any DeclarationObject], topLeadingPoint: CGPoint) {
            self.object = object
            self.topLeadingPoint = topLeadingPoint

            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: object,
                allDeclarationObjects: allDeclarationObjects
            )
            self.conformedProtocolObjects = conformedProtocolObjects

            var allAnnotatedDecl = [object.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.cases.map { $0.annotatedDecl })
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

            details = [
                DetailReducer.State(
                    objects: conformedProtocolObjects,
                    kind: .protocolConformance,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.cases,
                    kind: .case,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.initializers,
                    kind: .initializers,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.variables,
                    kind: .variables,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: bodyWidth
                ),
                DetailReducer.State(
                    objects: object.functions,
                    kind: .functions,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: bodyWidth
                )
            ]
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
        Reduce { _, action in
            switch action {
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
