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
        var topLeadingPoint: CGPoint
        var leadingArrowTerminalPoint: CGPoint {
            CGPoint(
                x: topLeadingPoint.x,
                y: topLeadingPoint.y
                    + ComponentSizeValues.itemHeight
                    + ComponentSizeValues.itemHeight/2
            )
        }
        var trailingArrowTerminalPoint: CGPoint {
            CGPoint(
                x: topLeadingPoint.x + bodyWidth,
                y: topLeadingPoint.y
                + ComponentSizeValues.itemHeight
                + ComponentSizeValues.itemHeight/2
            )
        }

        /// Width without ArrowTerminal.
        var bodyWidth: CGFloat

        public init(
            object: any HasHeader,
            topLeadingPoint: CGPoint,
            bodyWidth: CGFloat
        ) {
            self.object = object
            self.text = TextCellReducer.State(object: object, frameWidth: bodyWidth)
            self.topLeadingPoint = topLeadingPoint
            self.bodyWidth = bodyWidth
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
