//
//  TypeDeclVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import TypeDeclaration
import LanguageServerProtocol
import SwiftSyntax

final class TypeDeclVisitor: SyntaxVisitor {
    private var structDeclarations: [StructObject] = []

    private let locationConverter: SourceLocationConverter

    init(locatonConverter: SourceLocationConverter) {
        locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        print("\nVISIT: StructDeclSyntax(\(node.name.text))")

        print("SourceRange:")
        let sourceRange = node.sourceRange(converter: locationConverter)
        dump(sourceRange)

        print("MEMBERS:")
        let members = node.memberBlock.members
        dump(members)

        structDeclarations.append(
            StructObject(
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
        )

        return .visitChildren
    }

    func getStructDeclarations() -> [StructObject] {
        structDeclarations
    }
}
