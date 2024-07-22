//
//  TreeView.swift
//
//
//  Created by Ockey12 on 2024/07/22
//
//

import ComposableArchitecture
import SwiftUI

public struct TreeView: View {
    let store: StoreOf<TreeViewReducer>

    public init(store: StoreOf<TreeViewReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(store.scope(state: \.nodes, action: \.nodes)) { nodeStore in
                NodeView(store: nodeStore)
            }
        }
        .frame(width: store.frameWidth, height: store.frameHeight)
        .border(.red)
    }
}
