//
//  TextCellReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct TextCellReducer {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public static func == (lhs: TextCellReducer.State, rhs: TextCellReducer.State) -> Bool {
            lhs.id == rhs.id
            && lhs.object.id == rhs.object.id
        }

        public var id: UUID {
            object.id
        }

        let object: any DeclarationObject
        var topLeadingPoint: CGPoint
        var leadingArrowTerminalPoint: CGPoint {
            CGPoint(
                x: topLeadingPoint.x,
                y: topLeadingPoint.y
                    + ComponentSizeValues.itemHeight / 2
            )
        }

        var trailingArrowTerminalPoint: CGPoint {
            CGPoint(
                x: topLeadingPoint.x
                    + bodyWidth
                    + ComponentSizeValues.arrowTerminalWidth * 2
                    + ComponentSizeValues.borderWidth,
                y: topLeadingPoint.y
                    + ComponentSizeValues.itemHeight / 2
            )
        }

        let bodyWidth: CGFloat
    }

    public enum Action {
        case clicked
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .clicked:
                return .none
            }
        }
    }
}
