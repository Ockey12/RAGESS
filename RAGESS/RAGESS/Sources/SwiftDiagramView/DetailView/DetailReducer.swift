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
        let frameWidth: CGFloat
        var height: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight

            let items = itemHeight * CGFloat(texts.count)

            return header + items + bottomPadding + connectionHeight
        }

        public init(objects: [any DeclarationObject], kind: DetailKind, frameWidth: CGFloat) {
            @Dependency(\.uuid) var uuid
            id = uuid()
            texts = .init(uniqueElements: objects.map {
                TextCellReducer.State(object: $0, frameWidth: frameWidth)
            })
            self.kind = kind
            self.frameWidth = frameWidth
        }
    }

    public enum Action {
        case texts(IdentifiedActionOf<TextCellReducer>)
        case delegate(Delegate)

        public enum Delegate {
            case clickedCell(object: any DeclarationObject)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .texts(.element(id: id, action: .clicked)):
                guard let clickedObject = state.texts[id: id]?.object else {
                    return .none
                }
                return .send(.delegate(.clickedCell(object: clickedObject)))

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
