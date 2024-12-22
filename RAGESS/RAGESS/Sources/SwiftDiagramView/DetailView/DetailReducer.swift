//
//  DetailReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import DeclaredObject
import Dependencies
import Foundation

@Reducer
public struct DetailReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable, Equatable {
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
            objects: [DeclaredObject],
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
            texts = .init(textCells, uniquingIDsWith: { a, b in a})
            self.kind = kind
            self.topLeadingPoint = topLeadingPoint
            self.frameWidth = frameWidth
        }
    }

    public enum Action {
        case texts(IdentifiedActionOf<TextCellReducer>)
        case delegate(Delegate)

        public enum Delegate {
            case showImpactScopeButtonClicked(calleeUSR: [String])
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .texts(.element(id: _, action: .delegate(delegateAction))):
                switch delegateAction {
                case let .showImpactScopeButtonClicked(calleeUSR: calleeUSR):
                    return .send(.delegate(.showImpactScopeButtonClicked(calleeUSR: calleeUSR)))
                }

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
