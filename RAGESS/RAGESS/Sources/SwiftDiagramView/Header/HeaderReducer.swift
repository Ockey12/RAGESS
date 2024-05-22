//
//  HeaderReducer.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct HeaderReducer {
    public init() {}

    @ObservableState
    public struct State {
        var object: any HasHeader
        var bodyWidth: CGFloat

        public init(object: any HasHeader, bodyWidth: CGFloat) {
            self.object = object
            self.bodyWidth = bodyWidth
        }
    }

    public enum Action {
        case clicked
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clicked:
                print("\(state.object.name) clicked!")
                return .none
            }
        }
    }
}
