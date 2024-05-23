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
        let bodyWidth: CGFloat
        private let conformedProtocolObjects: [ProtocolObject]
        var height: CGFloat {
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

            return header + conformances + cases + variables + functions + connectionHeight
        }

        public init(object: EnumObject, allDeclarationObjects: [any DeclarationObject]) {
            self.object = object

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

            let maxWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            bodyWidth = max(calculateMaxTextWidth(allAnnotatedDecl), ComponentSizeValues.bodyMinWidth)

            header = HeaderReducer.State(object: object, bodyWidth: maxWidth)

            details = [
                DetailReducer.State(
                    objects: conformedProtocolObjects,
                    kind: .protocolConformance,
                    bodyWidth: maxWidth
                ),
                DetailReducer.State(
                    objects: object.cases,
                    kind: .case,
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
