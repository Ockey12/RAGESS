//
//  DirectoryCellViewReducer.swift
//
//
//  Created by Ockey12 on 2024/07/13
//
//

import ComposableArchitecture
import XcodeObject

@Reducer
struct DirectoryCellViewReducer {
    @ObservableState
    struct State {
        let directory: Directory
    }
}
