//
//  ClassView.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct ClassView: View {
    let store: StoreOf<ClassViewReducer>

    public init(store: StoreOf<ClassViewReducer>) {
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
    }
}

#Preview {
    var subClass = ClassObject(
        name: "SubClass",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public class SubClass",
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
    subClass.initializers = initializers

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
    subClass.variables = variableObjects

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
    subClass.functions = functionObjects

    let superClass = ClassObject(
        name: "SuperClass",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public class SuperClass",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let inheritDependency = DependencyObject(
        kind: .classInheritance,
        callerObject: .init(
            id: subClass.id,
            keyPath: .class(\.self)
        ),
        definitionObject: .init(
            id: superClass.id,
            keyPath: .class(\.self)
        )
    )

    subClass.objectsThatAreCalledByThisObject.append(inheritDependency)

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
            id: subClass.id,
            keyPath: .struct(\.self)
        ),
        definitionObject: .init(
            id: protocolObject.id,
            keyPath: .protocol(\.self)
        )
    )

    subClass.objectsThatAreCalledByThisObject.append(conformDependency)

    let allDeclarationObjects: [any DeclarationObject] = [
        subClass,
        superClass,
        protocolObject
    ]

    return VStack {
        ClassView(
            store: .init(
                initialState: ClassViewReducer.State(
                    object: subClass,
                    allDeclarationObjects: allDeclarationObjects
                ),
                reducer: {
                    ClassViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2300)
}
