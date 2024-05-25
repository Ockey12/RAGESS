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
        let rootObjectID: UUID
        var startPoint: CGPoint
        var endPoint: CGPoint
    }
}
