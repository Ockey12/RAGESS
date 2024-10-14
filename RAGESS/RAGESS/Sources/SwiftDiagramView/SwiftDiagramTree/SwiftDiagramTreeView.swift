//
//  TreeView.swift
//
//
//  Created by Ockey12 on 2024/07/22
//
//

import ComposableArchitecture
import SwiftUI

public struct SwiftDiagramTreeView: View {
    let store: StoreOf<SwiftDiagramTreeViewReducer>

    public init(store: StoreOf<SwiftDiagramTreeViewReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(store.scope(state: \.nodes, action: \.nodes)) { nodeStore in
                NodeView(store: nodeStore)
                    .offset(
                        x: nodeStore.topLeadingPoint.x,
                        y: nodeStore.topLeadingPoint.y
                    )
            }

            ForEach(store.scope(state: \.arrows, action: \.arrows)) { arrowStore in
                ArrowView(store: arrowStore)
            }
        }
        .frame(
            width: store.frameWidth,
            height: store.frameHeight,
            alignment: .topLeading
        )
    }
}
