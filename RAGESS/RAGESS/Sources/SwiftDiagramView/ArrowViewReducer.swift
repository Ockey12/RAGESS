//
//  ArrowViewReducer.swift
//
//
//  Created by Ockey12 on 2024/05/25
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

@Reducer
public struct ArrowViewReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable {
        public var id: UUID
        var startPointRootObjectID: UUID
        var endPointRootObjectID: UUID

        var leadingStartPoint: CGPoint
        var trailingStartPoint: CGPoint
        var leadingEndPoint: CGPoint
        var trailingEndPoint: CGPoint

        var beforeDragLeadingStartPoint: CGPoint
        var beforeDragTrailingStartPoint: CGPoint
        var beforeDragLeadingEndPoint: CGPoint
        var beforeDragTrailingEndPoint: CGPoint
//        var beforeDragStartPoint: CGPoint
//        var beforeDragEndPoint: CGPoint

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

        public init(
            startPointRootObjectID: UUID,
            endPointRootObjectID: UUID,
            leadingStartPoint: CGPoint,
            trailingStartPoint: CGPoint,
            leadingEndPoint: CGPoint,
            trailingEndPoint: CGPoint
        ) {
            @Dependency(\.uuid) var uuid
            id = uuid()
            self.startPointRootObjectID = startPointRootObjectID
            self.endPointRootObjectID = endPointRootObjectID

            self.leadingStartPoint = leadingStartPoint
            self.beforeDragLeadingStartPoint = leadingStartPoint

            self.trailingStartPoint = trailingStartPoint
            self.beforeDragTrailingStartPoint = trailingStartPoint

            self.leadingEndPoint = leadingEndPoint
            self.beforeDragLeadingEndPoint = leadingEndPoint

            self.trailingEndPoint = trailingEndPoint
            self.beforeDragTrailingEndPoint = trailingEndPoint
//
//            let combinations = [
//                (leadingStartPoint, leadingEndPoint),
//                (leadingStartPoint, trailingEndPoint),
//                (trailingStartPoint, leadingEndPoint),
//                (trailingStartPoint, trailingEndPoint)
//            ]
//
//            var minDistance = CGFloat.infinity
//            var startPoint = CGPoint()
//            var endPoint = CGPoint()
//            for (start, end) in combinations {
//                let distance = hypot(start.x - end.x, start.y - end.y)
//                if distance < minDistance {
//                    startPoint = start
//                    endPoint = end
//                    minDistance = distance
//                }
//            }
//
//            self.beforeDragStartPoint = startPoint
//            self.beforeDragEndPoint = endPoint
        }
    }
}
