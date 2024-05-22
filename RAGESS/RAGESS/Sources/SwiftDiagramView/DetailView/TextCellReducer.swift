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
struct TextCellReducer {
    @ObservableState
    struct State: Identifiable {
        var id: UUID {
            object.id
        }
        let object: any DeclarationObject
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
