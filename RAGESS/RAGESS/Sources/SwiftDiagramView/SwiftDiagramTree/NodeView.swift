//
//  NodeView.swift
//
//
//  Created by Ockey12 on 2024/07/22
//
//

import ComposableArchitecture
import SwiftUI

struct NodeView: View {
    let store: StoreOf<NodeReducer>

    var body: some View {
        VStack(spacing: -ComponentSizeValues.connectionHeight) {
            HeaderView(store: store.scope(state: \.header, action: \.header))

            ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                if !detailStore.texts.isEmpty {
                    DetailView(store: detailStore)
                }
            }
        }
        .frame(width: store.frameWidth, height: store.frameHeight)
    }
}
