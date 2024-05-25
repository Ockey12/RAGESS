//
//  ClassViewReducer.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct ClassViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            object.id
        }

        let object: ClassObject
        var header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        var topLeadingPoint: CGPoint
        let frameWidth: CGFloat
        private let conformedProtocolObjects: [ProtocolObject]
        private let superClassObject: ClassObject?
        var frameHeight: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight * 2 + bottomPadding

            let inheritance: CGFloat
            if let superClassObject {
                inheritance = connectionHeight + itemHeight + bottomPadding
            } else {
                inheritance = 0
            }

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
                + inheritance
                + conformances
                + initializers
                + variables
                + functions
                + connectionHeight
                + ComponentSizeValues.borderWidth
        }

        public init(object: ClassObject, allDeclarationObjects: [any DeclarationObject], topLeadingPoint: CGPoint) {
            self.object = object
            self.topLeadingPoint = topLeadingPoint

            let superClassObject = extractSuperClassObject(
                by: object,
                allDeclarationObjects: allDeclarationObjects
            )
            self.superClassObject = superClassObject

            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: object,
                allDeclarationObjects: allDeclarationObjects
            )
            self.conformedProtocolObjects = conformedProtocolObjects

            var allAnnotatedDecl = [object.annotatedDecl]
            if let superClassObject {
                allAnnotatedDecl.append(superClassObject.annotatedDecl)
            }
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.variables.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.functions.map { $0.annotatedDecl })

            let maxWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            frameWidth = max(calculateMaxTextWidth(allAnnotatedDecl), ComponentSizeValues.bodyMinWidth)
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

            header = HeaderReducer.State(
                object: object,
                topLeadingPoint: topLeadingPoint,
                bodyWidth: maxWidth
            )

            var details: [DetailReducer.State] = []

            if let superClassObject {
                details.append(
                    DetailReducer.State(
                        objects: [superClassObject],
                        kind: .superClass,
                        topLeadingPoint: topLeadingPoint,
                        frameWidth: maxWidth
                    )
                )
            }

            details.append(contentsOf: [
                DetailReducer.State(
                    objects: conformedProtocolObjects,
                    kind: .protocolConformance,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.initializers,
                    kind: .initializers,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.variables,
                    kind: .variables,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.functions,
                    kind: .functions,
                    topLeadingPoint: topLeadingPoint,
                    frameWidth: maxWidth
                )
            ])

            self.details = .init(uniqueElements: details)
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
