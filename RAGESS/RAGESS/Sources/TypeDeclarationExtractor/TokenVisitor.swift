//
//  TokenVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import SwiftSyntax
import DeclarationType
import LanguageServerProtocol

final class TokenVisitor: SyntaxRewriter {
    private var declarationTypes: [DeclarationType] = []

    private let locationConverter: SourceLocationConverter

    init(locatonConverter: SourceLocationConverter) {
        self.locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        return token
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        print("\nVISIT: StructDeclSyntax(\(node.name.text))")
        print("SourceRange:")

        let sourceRange = node.sourceRange(converter: self.locationConverter)
        dump(sourceRange)

        self.declarationTypes.append(
            DeclarationType(
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
                    ),
                dependsOn: [],
                dependsBy: []
            )
        )
        return DeclSyntax(node)
    }

    func getDeclarationTypes() -> [DeclarationType] {
        self.declarationTypes
    }
}
