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
        VStack(spacing: -45) {
            HeaderView(store: store.scope(state: \.header, action: \.header))

            ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                if !detailStore.items.isEmpty {
                    DetailView(store: detailStore)
                }
            }
        } // VStack
        .frame(width: store.bodyWidth)
    }
}

#Preview {
    var structObject = StructObject(
        name: "DebugStruct",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public struct DebugStruct",
//        annotatedDecl: "A",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let variableObjects = [
        VariableObject(
            name: "firstVariable",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "public var firstVariable: Int",
//            annotatedDecl: "A",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        VariableObject(
            name: "secondVariable",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "var firstVariable: String { get set }",
//            annotatedDecl: "A",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]

    structObject.variables = variableObjects

    return VStack {
        StructView(
            store: .init(
                initialState: StructViewReducer.State(object: structObject),
                reducer: { StructViewReducer() }
            )
        )
        .border(.pink)
    }
    .frame(width: 1500, height: 1000)
}
