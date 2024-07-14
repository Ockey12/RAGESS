//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/13
//  
//

import ComposableArchitecture
import SwiftUI

public struct FileTreeView: View {
    let store: StoreOf<FileTreeViewReducer>

    public init(store: StoreOf<FileTreeViewReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.scope(state: \.cells, action: \.cells)) { cellStore in
                CellView(store: cellStore)
            }
        }
    }
}
