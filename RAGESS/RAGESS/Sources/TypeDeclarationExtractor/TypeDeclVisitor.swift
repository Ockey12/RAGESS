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
        print("\nVISIT: StructDeclSyntax(\(node.name.text))")
        let sourceRange = node.sourceRange(converter: locationConverter)

        let currentStruct = StructObject(
            name: node.name.text,
            type: .struct,
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

        buffer.append(currentStruct)

        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        print("VISIT POST: StructDeclSyntax(\(node.name.text))")

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        guard let lastItem = buffer.popLast(),
              let currentStruct = lastItem as? StructObject else {
            fatalError("The type of the last element of buffer is not a \(StructObject.self).")
        }

        if 1 <= buffer.count {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            let lastIndex = buffer.endIndex - 1
            print("buffer: \(buffer.map { $0.name })")
            print("lastIndex: \(lastIndex)")
            buffer[lastIndex].nestingStructs.append(currentStruct)
        } else {
            structDeclarations.append(currentStruct)
            print("structDeclarations.append(\(currentStruct.name)")
            print("structDeclarations: \(structDeclarations.map { $0.name })")
        }
    }

    func getStructDeclarations() -> [StructObject] {
        structDeclarations
    }
}

enum SyntaxVisitError: Error {
    case doesNotMuchLastElementTypeOfBuffer
}
