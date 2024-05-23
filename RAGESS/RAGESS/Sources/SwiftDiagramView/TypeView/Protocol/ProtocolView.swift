//
//  ProtocolView.swift
//  
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct ProtocolView: View {
    let store: StoreOf<ProtocolViewReducer>

    public init(store: StoreOf<ProtocolViewReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: -ComponentSizeValues.connectionHeight) {
            HeaderView(store: store.scope(state: \.header, action: \.header))

            VStack(spacing: -ComponentSizeValues.connectionHeight) {
                ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                    if !detailStore.items.isEmpty {
                        DetailView(store: detailStore)
                    }
                }
            }
        } // VStack
        .frame(width: store.bodyWidth, height: store.height)
    }
}

#Preview {
    var protocolObject = ProtocolObject(
        name: "DebugProtocol",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public protocol DebugProtocol",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let allDeclarationObjects: [any DeclarationObject] = [
        protocolObject
    ]

    return VStack {
        ProtocolView(
            store: .init(
                initialState: ProtocolViewReducer.State(
                    object: protocolObject,
                    allDeclarationObjects: allDeclarationObjects
                ),
                reducer: {
                    ProtocolViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2300)
}
