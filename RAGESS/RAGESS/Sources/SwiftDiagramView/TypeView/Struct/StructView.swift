//
//  StructView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct StructView: View {
    let store: StoreOf<StructViewReducer>

    public init(store: StoreOf<StructViewReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView(store: store.scope(state: \.header, action: \.header))
        } // VStack
    }
}

#Preview {
    var structObject = StructObject(
        name: "DebugStruct",
        nameOffset: 0,
        fullPath: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    structObject.annotatedDecl = "public struct DebugStruct"

    return VStack {
        StructView(
            store: .init(
                initialState: StructViewReducer.State(object: structObject),
                reducer: { StructViewReducer() }
            )
        )
    }
    .frame(width: 1500, height: 1000)
}
