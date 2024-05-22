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
    public struct State: Identifiable {
        public var id: UUID {
            object.id
        }

        let object: any DeclarationObject
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
