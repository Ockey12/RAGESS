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
    public struct State {
        let object: StructObject
        let header: HeaderReducer.State
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

            return header + conformances + initializers + variables + functions + connectionHeight
        }

        public init(object: StructObject, allDeclarationObjects: [any DeclarationObject]) {
            self.object = object

            var allAnnotatedDecl = [object.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.variables.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.functions.map { $0.annotatedDecl })

            let maxWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            bodyWidth = max(calculateMaxTextWidth(allAnnotatedDecl), ComponentSizeValues.bodyMinWidth)

            header = HeaderReducer.State(object: object, bodyWidth: maxWidth)

            let protocolConformDependencies = object.objectsThatAreCalledByThisObject.filter { $0.kind == .protocolConformance }
            let conformedProtocolObjects = protocolConformDependencies.compactMap { dependency in
                allDeclarationObjects.first(where: { $0.id == dependency.definitionObject.id }) as? ProtocolObject
            }
            self.conformedProtocolObjects = conformedProtocolObjects

            details = [
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

func calculateMaxTextWidth(_ strings: [String]) -> CGFloat {
    var maxWidth: CGFloat = 0

    for string in strings {
        let width = string.systemSize50Width
        if maxWidth < width {
            maxWidth = width
        }
    }

    return maxWidth
}
