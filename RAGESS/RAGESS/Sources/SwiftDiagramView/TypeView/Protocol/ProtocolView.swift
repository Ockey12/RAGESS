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

            ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                if !detailStore.texts.isEmpty {
                    DetailView(store: detailStore)
                }
            }
        } // VStack
        .frame(width: store.frameWidth, height: store.frameHeight)
        .offset(x: store.topLeadingPoint.x, y: store.topLeadingPoint.y)
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
    protocolObject.initializers = initializers

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
    protocolObject.variables = variableObjects

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
    protocolObject.functions = functionObjects

    let parentProtocolObject = ProtocolObject(
        name: "ParentProtocol",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public protocol ParentProtocol",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let conformDependency = DependencyObject(
        kind: .protocolInheritance,
        callerObject: .init(
            rootObjectID: protocolObject.id,
            leafObjectID: protocolObject.id,
            keyPath: .struct(\.self)
        ),
        definitionObject: .init(
            rootObjectID: parentProtocolObject.id,
            leafObjectID: parentProtocolObject.id,
            keyPath: .protocol(\.self)
        )
    )

    protocolObject.objectsThatAreCalledByThisObject.append(conformDependency)

    let allDeclarationObjects: [any DeclarationObject] = [
        protocolObject,
        parentProtocolObject
    ]

    return VStack {
        ProtocolView(
            store: .init(
                initialState: ProtocolViewReducer.State(
                    object: protocolObject,
                    allDeclarationObjects: allDeclarationObjects,
                    topLeadingPoint: CGPoint(x: 0, y: 0)
                ),
                reducer: {
                    ProtocolViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2300)
}
