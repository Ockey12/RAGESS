//
//  TextCellPopover.swift
//
//  
//  Created by Ockey12 on 2024/12/12
//  
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct TextCellPopoverReducer {
    @ObservableState
    public struct State {
        let fullPath: String
    }
}
