//
//  TypeDeclVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import LanguageServerProtocol
import SwiftSyntax
import TypeDeclaration

final class TypeDeclVisitor: SyntaxVisitor {
    let fullPath: String
    private var structDeclarations: [StructObject] = []
    private var classDeclarations: [ClassObject] = []
    private var enumDeclarations: [EnumObject] = []
    private var variableDeclarations: [VariableObject] = []
    private var functionDeclarations: [FunctionObject] = []
    private var buffer: [any DeclarationObject] = []

    private let locationConverter: SourceLocationConverter

    init(in fullPath: String, locatonConverter: SourceLocationConverter) {
        self.fullPath = fullPath
        locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    // MARK: StructDeclSyntax

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(StructDeclSyntax(\(node.name.text)))")
        #endif
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentStruct = StructObject(
            name: node.name.text,
            fullPath: fullPath,
            sourceRange:
            Position(
                line: sourceRange.start.line,
                utf16index: sourceRange.start.column
            )
                ... Position(
                    line: sourceRange.end.line,
                    utf16index: sourceRange.end.column
                )
        )

        appendToBuffer(currentStruct)

        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        #if DEBUG
            print("\nvisitPost(StructDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let lastItem = buffer.popLast(),
              let currentStruct = lastItem as? StructObject else {
            fatalError("The type of the last element of buffer is not a \(StructObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? TypeDeclaration else {
                fatalError("The type of the last element of buffer does not conform to \(TypeDeclaration.self).")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingStructs.append(\(currentStruct.name))")
            #endif
            ownerTypeObject.nestingStructs.append(currentStruct)
            buffer.append(ownerTypeObject)
        } else {
            #if DEBUG
                print("structDeclarations.append(\(currentStruct.name))")
                print("- \(structDeclarations.map { $0.name })")
            #endif
            structDeclarations.append(currentStruct)
            #if DEBUG
                print("+ \(structDeclarations.map { $0.name })")
            #endif
        }
    }

    func getStructDeclarations() -> [StructObject] {
        structDeclarations
    }

    // MARK: ClassDeclSyntax

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(ClassDeclSyntax(\(node.name.text)))")
        #endif
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentClass = ClassObject(
            name: node.name.text,
            fullPath: fullPath,
            sourceRange: Position(
                line: sourceRange.start.line,
                utf16index: sourceRange.start.column
            )
                ... Position(
                    line: sourceRange.end.line,
                    utf16index: sourceRange.end.column
                )
        )

        appendToBuffer(currentClass)

        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        #if DEBUG
            print("\nvisitPost(ClassDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let lastItem = buffer.popLast(),
              let currentClass = lastItem as? ClassObject else {
            fatalError("The type of the last element of buffer is not a \(ClassObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? TypeDeclaration else {
                fatalError("The type of the last element of buffer does not conform to \(TypeDeclaration.self).")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingClasses.append(\(currentClass.name))")
            #endif
            ownerTypeObject.nestingClasses.append(currentClass)
            buffer.append(ownerTypeObject)
        } else {
            #if DEBUG
                print("classDeclarations.append(\(currentClass.name))")
                print("- \(classDeclarations.map { $0.name })")
            #endif
            classDeclarations.append(currentClass)
            #if DEBUG
                print("+ \(classDeclarations.map { $0.name })")
            #endif
        }
    }

    func getClassDeclarations() -> [ClassObject] {
        classDeclarations
    }

    // MARK: EnumDeclSyntax

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(EnumDeclSyntax(\(node.name.text)))")
        #endif
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentEnum = EnumObject(
            name: node.name.text,
            fullPath: fullPath,
            sourceRange: Position(
                line: sourceRange.start.line,
                utf16index: sourceRange.start.column
            )
                ... Position(
                    line: sourceRange.end.line,
                    utf16index: sourceRange.end.column
                )
        )

        appendToBuffer(currentEnum)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        #if DEBUG
            print("\nvisitPost(EnumDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let lastItem = buffer.popLast(),
              let currentEnum = lastItem as? EnumObject else {
            fatalError("The type of the last element of buffer is not a \(EnumObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? TypeDeclaration else {
                fatalError("The type of the last element of buffer does not conform to \(TypeDeclaration.self).")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingEnums.append(\(currentEnum.name))")
            #endif
            ownerTypeObject.nestingEnums.append(currentEnum)
            buffer.append(ownerTypeObject)
        } else {
            #if DEBUG
                print("classDeclarations.append(\(currentEnum.name))")
                print("- \(enumDeclarations.map { $0.name })")
            #endif
            enumDeclarations.append(currentEnum)
            #if DEBUG
                print("+ \(enumDeclarations.map { $0.name })")
            #endif
        }
    }

    func getEnumDeclarations() -> [EnumObject] {
        enumDeclarations
    }

    //MARK: VariableDeclSyntax

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
#if DEBUG
        print("\nvisit(VariableDeclSyntax(\(node)))")
#endif
        let array = Array(node.bindings)
        guard !array.isEmpty else {
            #if DEBUG
                print("The contents of the variable do not exist.")
            #endif
            return .visitChildren
        }

        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentVariable = VariableObject(
            //FIXME: This element does not necessarily represent the name of the variable.
            // For example, in the case of Tuple Decomposition, the tuple would be the name of the variable.
            // When `let (a, b, c) = (0, 1, 2)`, the variable name becomes “(a, b, c)”.
            name: array[0].pattern.description,
            fullPath: fullPath,
            sourceRange: Position(
                line: sourceRange.start.line,
                utf16index: sourceRange.start.column
            )
            ... Position(
                line: sourceRange.end.line,
                utf16index: sourceRange.end.column
            )
        )
        dump(currentVariable)

        appendToBuffer(currentVariable)

        return .visitChildren
    }

    override func visitPost(_ node: VariableDeclSyntax) {
#if DEBUG
        print("\nvisitPost(VariableDeclSyntax(\(node)))")
#endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

#if DEBUG
        print("buffer.popLast()")
        print("- \(buffer.map { $0.name })")
#endif

        guard let lastItem = buffer.popLast(),
              let currentVariable = lastItem as? VariableObject else {
            fatalError("The type of the last element of buffer is not a \(VariableObject.self).")
        }

#if DEBUG
        print("+ \(buffer.map { $0.name })")
#endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerObject = owner as? VariableOwner else {
                fatalError("The type of the last element of buffer does not conform to \(VariableOwner.self).")
            }
#if DEBUG
            print("buffer[\(buffer.count)].variables.append(\(currentVariable.name))")
#endif
            ownerObject.variables.append(currentVariable)
            buffer.append(ownerObject)
        } else {
#if DEBUG
            print("variableDeclarations.append(\(currentVariable.name))")
            print("- \(variableDeclarations.map { $0.name })")
#endif
            variableDeclarations.append(currentVariable)
#if DEBUG
            print("+ \(variableDeclarations.map { $0.name })")
#endif
        }
    }

    // MARK: FunctionDeclSyntax

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(FunctionDeclSyntax(\(node.name.text)))")
        #endif
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentFunction = FunctionObject(
            name: node.name.text,
            fullPath: fullPath,
            sourceRange: Position(
                line: sourceRange.start.line,
                utf16index: sourceRange.start.column
            )
                ... Position(
                    line: sourceRange.end.line,
                    utf16index: sourceRange.end.column
                )
        )

        appendToBuffer(currentFunction)

        return .visitChildren
    }

    override func visitPost(_ node: FunctionDeclSyntax) {
        #if DEBUG
            print("\nvisitPost(FunctionDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let lastItem = buffer.popLast(),
              let currentFunction = lastItem as? FunctionObject else {
            fatalError("The type of the last element of buffer is not a \(FunctionObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerObject = owner as? FunctionOwner else {
                fatalError("The type of the last element of buffer does not conform to \(FunctionOwner.self).")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].functions.append(\(currentFunction.name))")
            #endif
            ownerObject.functions.append(currentFunction)
            buffer.append(ownerObject)
        } else {
            #if DEBUG
                print("functionDeclarations.append(\(currentFunction.name))")
                print("- \(functionDeclarations.map { $0.name })")
            #endif
            functionDeclarations.append(currentFunction)
            #if DEBUG
                print("+ \(functionDeclarations.map { $0.name })")
            #endif
        }
    }

    func getFunctionDeclarations() -> [FunctionObject] {
        functionDeclarations
    }
}

extension TypeDeclVisitor {
    private func appendToBuffer(_ typeObject: any DeclarationObject) {
        #if DEBUG
            print("buffer.append(\(typeObject.name))")
            print("- \(buffer.map { $0.name })")
        #endif

        buffer.append(typeObject)

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif
    }
}

enum SyntaxVisitError: Error {
    case doesNotMuchLastElementTypeOfBuffer
}
