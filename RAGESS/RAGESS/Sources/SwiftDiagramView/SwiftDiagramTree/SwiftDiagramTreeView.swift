//
//  SwiftDiagramTreeView.swift
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

    private enum ScrollAnchor {
        case selected
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    if let first = store.nodes.first {
                        Color.clear
                            .frame(width: 1, height: 1)
                            .id(ScrollAnchor.selected)
                            .position(
                                x: first.topLeadingPoint.x - 200,
                                y: first.topLeadingPoint.y
                            )
                    }
                    ForEach(store.scope(state: \.nodes, action: \.nodes)) { nodeStore in
                        NodeView(store: nodeStore)
                            .offset(
                                x: nodeStore.topLeadingPoint.x,
                                y: nodeStore.topLeadingPoint.y
                            )
                            .id(nodeStore.id)
                    }
                    .onChange(of: store.nodes) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(ScrollAnchor.selected, anchor: .leading)
                        }
                    }

                    ForEach(store.scope(state: \.arrows, action: \.arrows)) { arrowStore in
                        ArrowView(store: arrowStore)
                            .opacity(arrowStore.opacity)
                    }
                }
                .frame(
                    width: store.frameWidth,
                    height: store.frameHeight,
                    alignment: .topLeading
                )
                .padding(300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
