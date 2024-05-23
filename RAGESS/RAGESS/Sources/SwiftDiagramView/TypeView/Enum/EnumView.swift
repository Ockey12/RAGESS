//
//  EnumView.swift
//  
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct EnumView: View {
    let store: StoreOf<EnumViewReducer>

    public init(store: StoreOf<EnumViewReducer>) {
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
    var enumObject = EnumObject(
        name: "DebugEnum",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public struct DebugEnum",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let allDeclarationObjects: [any DeclarationObject] = [
        enumObject
    ]

    return VStack {
        EnumView(
            store: .init(
                initialState: EnumViewReducer.State(
                    object: enumObject,
                    allDeclarationObjects: allDeclarationObjects
                ),
                reducer: {
                    EnumViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2000)
}
