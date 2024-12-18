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
                                x: first.topLeadingPoint.x,
                                y: first.topLeadingPoint.y
                            )
                    }
                    ForEach(store.scope(state: \.nodes, action: \.nodes)) { nodeStore in
                        NodeView(store: nodeStore)
                            .offset(
                                x: nodeStore.topLeadingPoint.x + ComponentSizeValues.PaddingAroundSwiftDiagramTreeView,
                                y: nodeStore.topLeadingPoint.y + ComponentSizeValues.PaddingAroundSwiftDiagramTreeView
                            )
                            .id(nodeStore.id)
                    }
                    .onChange(of: store.nodes) { _, _ in
                        withAnimation {
                            proxy.scrollTo(ScrollAnchor.selected, anchor: .leading)
                        }
                    }

                    ForEach(store.scope(state: \.arrows, action: \.arrows)) { arrowStore in
                        ArrowView(store: arrowStore)
                            .opacity(arrowStore.opacity)
                    }
                }
                .scaleEffect(store.swiftDiagramScale)
                .frame(
                    width: (store.frameWidth + ComponentSizeValues.PaddingAroundSwiftDiagramTreeView * 2) * store.swiftDiagramScale,
                    height: (store.frameHeight + ComponentSizeValues.PaddingAroundSwiftDiagramTreeView * 2) * store.swiftDiagramScale
                )

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
