//
//  TextCellReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import DeclaredObject
import Foundation

@Reducer
public struct TextCellReducer {
    @Reducer
    public enum Destination {
        case popover(TextCellPopoverReducer)
    }

    @ObservableState
    public struct State: Identifiable, Equatable {
        public static func == (lhs: TextCellReducer.State, rhs: TextCellReducer.State) -> Bool {
            lhs.id == rhs.id
                && lhs.object.id == rhs.object.id
        }

        public var id: UUID {
            object.id
        }

        let object: DeclaredObject
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
        @Presents var destination: Destination.State?
    }

    public enum Action {
        case clicked
        case destination(PresentationAction<Destination.Action>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clicked:
                print(state.object.name)
                state.destination = .popover(TextCellPopoverReducer.State(fullPath: state.object.fullPath))
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
