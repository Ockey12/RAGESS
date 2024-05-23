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
        let header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        let bodyWidth: CGFloat
        private let conformedProtocolObjects: [ProtocolObject]
        private let superClassObject: ClassObject?
        var height: CGFloat {
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

            return header + inheritance + conformances + initializers + variables + functions + connectionHeight
        }

        public init(object: ClassObject, allDeclarationObjects: [any DeclarationObject]) {
            self.object = object

            let superClassObject = extractSuperClassObjects(
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
            bodyWidth = max(calculateMaxTextWidth(allAnnotatedDecl), ComponentSizeValues.bodyMinWidth)

            header = HeaderReducer.State(object: object, bodyWidth: maxWidth)

            var details: [DetailReducer.State] = []

            if let superClassObject {
                details.append(
                    DetailReducer.State(
                        objects: [superClassObject],
                        kind: .superClass,
                        bodyWidth: maxWidth
                    )
                )
            }

            details.append(contentsOf: [
                DetailReducer.State(
                    objects: conformedProtocolObjects,
                    kind: .protocolConformance,
                    bodyWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.initializers,
                    kind: .initializers,
                    bodyWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.variables,
                    kind: .variables,
                    bodyWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.functions,
                    kind: .functions,
                    bodyWidth: maxWidth
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