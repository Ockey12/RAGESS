//
//  DetailReducer.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
struct DetailReducer {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<TextCellReducer.State>
        let bodyWidth: CGFloat

        init(objects: [any DeclarationObject], bodyWidth: CGFloat) {
            items = .init(uniqueElements: objects.map {
                TextCellReducer.State(object: $0, bodyWidth: bodyWidth)
            })
            self.bodyWidth = bodyWidth
        }
    }

    enum Action {
        case items(IdentifiedActionOf<TextCellReducer>)
    }

    var body: some ReducerOf<Self> {
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
