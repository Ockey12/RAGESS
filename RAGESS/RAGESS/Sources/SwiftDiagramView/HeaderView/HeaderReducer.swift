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
        var frameWidth: CGFloat

        public init(object: any HasHeader, frameWidth: CGFloat) {
            self.object = object
            self.text = TextCellReducer.State(object: object, frameWidth: frameWidth)
            self.frameWidth = frameWidth
        }
    }

    public enum Action {
        case text(TextCellReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .text:
                return .none
            }
        }
    }
}
