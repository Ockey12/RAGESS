//
//  Visitor.swift
//
//
//  Created by Ockey12 on 2024/05/12
//
//

import SwiftSyntax
import TypeDeclaration

final class Visitor: SyntaxVisitor {
    private let locationConverter: SourceLocationConverter
    private var offsets: [Int] = []

    init(locationConverter: SourceLocationConverter) {
        self.locationConverter = locationConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(DeclReferenceExprSyntax(\(node.baseName.text)))")
            print("╰─node.trimmedByteRange.offset: \(node.trimmedByteRange.offset)")
        #endif

        offsets.append(node.trimmedByteRange.offset)

        return .visitChildren
    }

    override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(IdentifierTypeSyntax(\(node.name.text)))")
            print("╰─node.trimmedByteRange.offset: \(node.trimmedByteRange.offset)")
        #endif

        offsets.append(node.trimmedByteRange.offset)

        return .visitChildren
    }

    func getOffsets() -> [Int] {
        offsets
    }
}
