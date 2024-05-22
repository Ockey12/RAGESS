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

    public struct State {
        let object: StructObject
        let header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>
        let bodyWidth: CGFloat

        public init(object: StructObject) {
            self.object = object

            var allAnnotatedDecl = [object.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.variables.map { $0.annotatedDecl })
            allAnnotatedDecl.append(contentsOf: object.functions.map { $0.annotatedDecl })

            let maxWidth = calculateMaxTextWidth(allAnnotatedDecl)
            bodyWidth = max(maxWidth, ComponentSizeValues.bodyMinWidth)

            header = HeaderReducer.State(object: object, bodyWidth: maxWidth)

            details = [
                DetailReducer.State(objects: object.initializers, bodyWidth: maxWidth),
                DetailReducer.State(objects: object.variables, bodyWidth: maxWidth),
                DetailReducer.State(objects: object.functions, bodyWidth: maxWidth),
            ]
        }
    }

    public enum Action {
        case header(HeaderReducer.Action)
        case details(IdentifiedActionOf<DetailReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
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
