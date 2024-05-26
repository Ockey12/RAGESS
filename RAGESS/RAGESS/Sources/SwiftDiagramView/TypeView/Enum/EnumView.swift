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

            ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                if !detailStore.texts.isEmpty {
                    DetailView(store: detailStore)
                }
            }
        } // VStack
        .frame(width: store.frameWidth, height: store.frameHeight)
        .offset(x: store.topLeadingPoint.x, y: store.topLeadingPoint.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    store.send(.dragged(value.translation))
                }
                .onEnded { value in
                    store.send(.dropped(value.translation))
                }
        )
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

    let caseObjects = [
        EnumObject.CaseObject(
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "case Sunday",
            sourceCode: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        EnumObject.CaseObject(
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "case text(String)",
            sourceCode: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        EnumObject.CaseObject(
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "case count(Int)",
            sourceCode: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        EnumObject.CaseObject(
            nameOffset: 0,
            fullPath: "",
            annotatedDecl: "case duration(Double)",
            sourceCode: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]
    enumObject.cases = caseObjects

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
    enumObject.variables = variableObjects

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
    enumObject.functions = functionObjects

    let protocolObject = ProtocolObject(
        name: "ConformedProtocol",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public protocol ConformedProtocol",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let conformDependency = DependencyObject(
        kind: .protocolConformance,
        callerObject: .init(
            rootObjectID: enumObject.id,
            leafObjectID: enumObject.id,
            keyPath: .struct(\.self)
        ),
        definitionObject: .init(
            rootObjectID: protocolObject.id,
            leafObjectID: protocolObject.id,
            keyPath: .protocol(\.self)
        )
    )

    enumObject.objectsThatAreCalledByThisObject.append(conformDependency)

    let allDeclarationObjects: [any DeclarationObject] = [
        enumObject,
        protocolObject
    ]

    return VStack {
        EnumView(
            store: .init(
                initialState: EnumViewReducer.State(
                    object: enumObject,
                    allDeclarationObjects: allDeclarationObjects,
                    topLeadingPoint: CGPoint(x: 0, y: 0)
                ),
                reducer: {
                    EnumViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2000)
}
