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
        var items: IdentifiedArrayOf<TextCellReducer.State>
        let kind: DetailKind
        let bodyWidth: CGFloat
        var height: CGFloat {
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText
            let connectionHeight = ComponentSizeValues.connectionHeight

            let header = itemHeight

            let items = itemHeight*CGFloat(items.count)

            return header + items + bottomPadding + connectionHeight
        }

        public init(objects: [any DeclarationObject], kind: DetailKind, bodyWidth: CGFloat) {
            @Dependency(\.uuid) var uuid
            id = uuid()
            items = .init(uniqueElements: objects.map {
                TextCellReducer.State(object: $0, bodyWidth: bodyWidth)
            })
            self.kind = kind
            self.bodyWidth = bodyWidth
        }
    }

    public enum Action {
        case items(IdentifiedActionOf<TextCellReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .items:
                return .none
            }
        }
        .forEach(\.items, action: \.items) {
            TextCellReducer()
        }
    }
}
