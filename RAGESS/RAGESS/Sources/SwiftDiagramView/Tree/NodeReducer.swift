//
//  NodeReducer.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import Foundation

@Reducer
public struct NodeReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: UUID {
            object.id
        }

        let object: GenericTypeObject

        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let topLeadingPoint: CGPoint

        public init(
            object: GenericTypeObject,
            frameWidth: CGFloat,
            frameHeight: CGFloat,
            topLeadingPoint: CGPoint
        ) {
            self.object = object
            self.frameWidth = frameWidth
            self.frameHeight = frameHeight
            self.topLeadingPoint = topLeadingPoint
        }
    }
}
