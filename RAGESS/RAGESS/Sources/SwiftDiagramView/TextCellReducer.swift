//
//  TextCellReducer.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import ComposableArchitecture
import Foundation

@Reducer
struct TextCellReducer {
    @ObservableState
    struct State {
        let text: String
        let bodyWidth: CGFloat
    }

    enum Action {
        case clicked
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clicked:
                return .none
            }
        }
    }
}
