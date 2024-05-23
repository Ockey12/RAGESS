//
//  ProtocolViewReducer.swift
//
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct ProtocolViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            object.id
        }

        let object: ProtocolObject
        let header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        let bodyWidth: CGFloat
        private let parentProtocolObjects: [ProtocolObject]
        var height: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight * 2 + bottomPadding

            let parentProtocols: CGFloat
            if parentProtocolObjects.isEmpty {
                parentProtocols = 0
            } else {
                parentProtocols = connectionHeight + itemHeight * CGFloat(parentProtocolObjects.count) + bottomPadding
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

            return header + parentProtocols + initializers + variables + functions + connectionHeight
        }

        public init(object: ProtocolObject, allDeclarationObjects: [any DeclarationObject]) {
            self.object = object

            let parentProtocolObjects = extractParentProtocolObjects(
                by: object,
                allDeclarationObjects: allDeclarationObjects
            )
            self.parentProtocolObjects = parentProtocolObjects

            var allAnnotatedDecl = [object.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: parentProtocolObjects.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl })
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
                    objects: parentProtocolObjects,
                    kind: .parentProtocol,
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

