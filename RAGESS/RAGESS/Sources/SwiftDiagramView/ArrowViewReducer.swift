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
        var startPoint: CGPoint
        var endPoint: CGPoint

        public init(
            startPointRootObjectID: UUID,
            endPointRootObjectID: UUID,
            startPoint: CGPoint,
            endPoint: CGPoint
        ) {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
            self.startPointRootObjectID = startPointRootObjectID
            self.endPointRootObjectID = endPointRootObjectID
            self.startPoint = startPoint
            self.endPoint = endPoint
        }
    }
}
