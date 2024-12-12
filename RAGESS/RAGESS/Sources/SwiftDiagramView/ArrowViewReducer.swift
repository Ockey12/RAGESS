//
//  ArrowViewReducer.swift
//
//
//  Created by Ockey12 on 2024/05/25
//
//

import ComposableArchitecture
import DependencyObject
import Foundation

@Reducer
public struct ArrowViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID
        var dependency: DependencyObject

        var leadingStartPoint: CGPoint
        var trailingStartPoint: CGPoint
        var leadingEndPoint: CGPoint
        var trailingEndPoint: CGPoint

        var beforeDragLeadingStartPoint: CGPoint
        var beforeDragTrailingStartPoint: CGPoint
        var beforeDragLeadingEndPoint: CGPoint
        var beforeDragTrailingEndPoint: CGPoint

        var startPoint: CGPoint {
            let combinations = [
                (leadingStartPoint, leadingEndPoint),
                (leadingStartPoint, trailingEndPoint),
                (trailingStartPoint, leadingEndPoint),
                (trailingStartPoint, trailingEndPoint)
            ]
            var minDistance = CGFloat.infinity
            var startPoint = CGPoint()
            for (start, end) in combinations {
                let distance = hypot(start.x - end.x, start.y - end.y)
                if distance < minDistance {
                    startPoint = start
                    minDistance = distance
                }
            }
            return startPoint
        }

        var endPoint: CGPoint {
            let combinations = [
                (leadingStartPoint, leadingEndPoint),
                (leadingStartPoint, trailingEndPoint),
                (trailingStartPoint, leadingEndPoint),
                (trailingStartPoint, trailingEndPoint)
            ]

            var minDistance = CGFloat.infinity
            var endPoint = CGPoint()
            for (start, end) in combinations {
                let distance = hypot(start.x - end.x, start.y - end.y)
                if distance < minDistance {
                    endPoint = end
                    minDistance = distance
                }
            }
            return endPoint
        }

        var startPointSide: Side {
            if startPoint == leadingStartPoint {
                return .leading
            } else {
                return .trailing
            }
        }

        enum Side {
            case leading
            case trailing
        }

        public init(
            dependency: DependencyObject,
            leadingStartPoint: CGPoint,
            trailingStartPoint: CGPoint,
            leadingEndPoint: CGPoint,
            trailingEndPoint: CGPoint
        ) {
            @Dependency(\.uuid) var uuid
            id = uuid()
            self.dependency = dependency

            self.leadingStartPoint = leadingStartPoint
            beforeDragLeadingStartPoint = leadingStartPoint

            self.trailingStartPoint = trailingStartPoint
            beforeDragTrailingStartPoint = trailingStartPoint

            self.leadingEndPoint = leadingEndPoint
            beforeDragLeadingEndPoint = leadingEndPoint

            self.trailingEndPoint = trailingEndPoint
            beforeDragTrailingEndPoint = trailingEndPoint
        }
    }
}
