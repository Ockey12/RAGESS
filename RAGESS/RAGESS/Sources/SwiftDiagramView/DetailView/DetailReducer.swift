//
//  DetailReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import Dependencies
import Foundation
import TypeDeclaration

@Reducer
public struct DetailReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public let id: UUID
        var texts: IdentifiedArrayOf<TextCellReducer.State>
        let kind: DetailKind
        var topLeadingPoint: CGPoint
        let frameWidth: CGFloat
        var height: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight

            let items = itemHeight * CGFloat(texts.count)

            return header + items + bottomPadding + connectionHeight
        }

        public init(
            objects: [any DeclarationObject],
            kind: DetailKind,
            topLeadingPoint: CGPoint,
            frameWidth: CGFloat
        ) {
            @Dependency(\.uuid) var uuid
            id = uuid()

            var textCells: [TextCellReducer.State] = []
            var textCellTopLeadingPoint = CGPoint(
                x: topLeadingPoint.x,
                y: topLeadingPoint.y + ComponentSizeValues.connectionHeight
            )
            for object in objects {
                textCells.append(
                    .init(
                        object: object,
                        topLeadingPoint: textCellTopLeadingPoint,
                        bodyWidth: frameWidth
                    )
                )
                textCellTopLeadingPoint = CGPoint(
                    x: textCellTopLeadingPoint.x,
                    y: textCellTopLeadingPoint.y + ComponentSizeValues.itemHeight
                )
            }
            texts = .init(uniqueElements: textCells)
            self.kind = kind
            self.topLeadingPoint = topLeadingPoint
            self.frameWidth = frameWidth
        }
    }

    public enum Action {
        case texts(IdentifiedActionOf<TextCellReducer>)
        case delegate(Delegate)

        public enum Delegate {
            case clickedCell(
                object: any DeclarationObject,
                leadingArrowTerminalPoint: CGPoint,
                trailingArrowTerminalPoint: CGPoint
            )
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .texts(.element(id: id, action: .clicked)):
                guard let clickedCell = state.texts[id: id] else {
                    return .none
                }
                return .send(.delegate(.clickedCell(
                    object: clickedCell.object,
                    leadingArrowTerminalPoint: clickedCell.leadingArrowTerminalPoint,
                    trailingArrowTerminalPoint: clickedCell.trailingArrowTerminalPoint
                )))

            case .texts:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.texts, action: \.texts) {
            TextCellReducer()
        }
    }
}
