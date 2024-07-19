//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/19
//  
//

import ComposableArchitecture
import Foundation

@Reducer
struct NodeReducer {
    @ObservableState
    struct State: Identifiable, Equatable {
        var id: UUID {
            object.id
        }
        let object: GenericTypeObject

        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let topLeadingPoint: CGPoint
    }
}
