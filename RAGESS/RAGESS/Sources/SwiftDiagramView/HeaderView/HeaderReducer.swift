//
//  HeaderReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct HeaderReducer {
    public init() {}

    @ObservableState
    public struct State {
        var object: any HasHeader
        var text: TextCellReducer.State
        var bodyWidth: CGFloat

        public init(object: any HasHeader, bodyWidth: CGFloat) {
            self.object = object
            self.text = TextCellReducer.State(object: object, bodyWidth: bodyWidth)
            self.bodyWidth = bodyWidth
        }
    }

    public enum Action {
        case text(TextCellReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.text, action: \.text) {
            TextCellReducer()
        }
    }
}
