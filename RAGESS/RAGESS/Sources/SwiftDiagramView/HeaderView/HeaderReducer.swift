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
        var frameWidth: CGFloat

        public init(object: any HasHeader, frameWidth: CGFloat) {
            self.object = object
            self.frameWidth = frameWidth
        }
    }

    public enum Action {
        case nameClicked
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .nameClicked:
                return .none
            }
        }
    }
}
