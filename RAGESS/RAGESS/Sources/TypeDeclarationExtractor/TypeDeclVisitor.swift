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
    private var structDeclarations: [StructObject] = []
    private var buffer: [any TypeDeclaration] = []

    private let locationConverter: SourceLocationConverter

    init(locatonConverter: SourceLocationConverter) {
        locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(StructDeclSyntax(\(node.name.text)))")
        #endif
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentStruct = StructObject(
            name: node.name.text,
            fullPath: "",
            sourceCode: "",
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

        #if DEBUG
            print("buffer.append(\(node.name.text))")
            print("- \(buffer.map { $0.name })")
        #endif

        buffer.append(currentStruct)

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

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
}

enum SyntaxVisitError: Error {
    case doesNotMuchLastElementTypeOfBuffer
}
