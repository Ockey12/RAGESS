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
    var structObject = StructObject(
        name: "DebugStruct",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public struct DebugStruct",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let initializers = [
        InitializerObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "public init()",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        InitializerObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "public init()",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        InitializerObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "public init()",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]
    structObject.initializers = initializers

    let variableObjects = [
        VariableObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "public var firstVariable: Int",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        VariableObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "var variable: String { get set }",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        VariableObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "var variable: String { get set }",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]
    structObject.variables = variableObjects

    let functionObjects = [
        FunctionObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        FunctionObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "private func findProperty<T: TypeNestable>(in object: T, matching: (any DeclarationObject) -> Bool) -> PartialKeyPath<T>?",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        FunctionObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "funcion",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        FunctionObject(
            name: "",
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "funcion",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]
    structObject.functions = functionObjects

    return VStack {
        StructView(
            store: .init(
                initialState: StructViewReducer.State(object: structObject),
                reducer: { StructViewReducer() }
            )
        )
        .border(.pink)
    }
    .frame(width: 3500, height: 2000)
}
