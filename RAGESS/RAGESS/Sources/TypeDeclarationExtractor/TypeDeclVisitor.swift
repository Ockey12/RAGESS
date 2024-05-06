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
    private var buffer: [any TypeDeclaration] = []

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
            let lastIndex = buffer.endIndex - 1
            #if DEBUG
                print("buffer[\(lastIndex)].nestingStructs.append(\(currentStruct.name))")
            #endif
            buffer[lastIndex].nestingStructs.append(currentStruct)
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
            let lastIndex = buffer.endIndex - 1
            #if DEBUG
                print("buffer[\(lastIndex)].nestingClasses.append(\(currentClass.name))")
            #endif
            buffer[lastIndex].nestingClasses.append(currentClass)
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
            let lastIndex = buffer.endIndex - 1
            #if DEBUG
                print("buffer[\(lastIndex)].nestingEnums.append(\(currentEnum.name))")
            #endif
            buffer[lastIndex].nestingEnums.append(currentEnum)
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
}

extension TypeDeclVisitor {
    private func appendToBuffer(_ typeObject: any TypeDeclaration) {
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
