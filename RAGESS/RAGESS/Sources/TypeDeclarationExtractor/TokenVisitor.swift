//
//  TokenVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import SwiftSyntax

//final class TokenVisitor: SyntaxVisitor {
//    private let locationConverter: SourceLocationConverter
//
//    init(locatonConverter: SourceLocationConverter) {
//        self.locationConverter = locatonConverter
//        super.init(viewMode: .fixedUp)
//    }
//
//    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
//        return .visitChildren
//    }
//
//    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
//        print("SourceRange: \(node.sourceRange(converter: self.locationConverter))")
//        return .visitChildren
//    }
//}

final class TokenVisitor: SyntaxRewriter {
    private let locationConverter: SourceLocationConverter

    init(locatonConverter: SourceLocationConverter) {
        self.locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        return token
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {

        print("VISIT: StructDeclSyntax(\(node.name.text))")
        print("SourceRange:")
        dump(node.sourceRange(converter: self.locationConverter))
        return DeclSyntax(node)
    }
}
