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
    private(set) var referenceOffsets: [Int] = []
    private(set) var identifierTypeOffsets: [Int] = []
    private(set) var inheritOffsets: [Int] = []

    init(locationConverter: SourceLocationConverter) {
        self.locationConverter = locationConverter
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(DeclReferenceExprSyntax(\(node.baseName.text)))")
            print("╰─node.trimmedByteRange.offset: \(node.trimmedByteRange.offset)")
        #endif

        referenceOffsets.append(node.trimmedByteRange.offset)

        return .visitChildren
    }

    override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(IdentifierTypeSyntax(\(node.name.text)))")
            print("╰─node.trimmedByteRange.offset: \(node.trimmedByteRange.offset)")
        #endif

        identifierTypeOffsets.append(node.trimmedByteRange.offset)

        return .visitChildren
    }

    override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
#if DEBUG
        print("\nvisit(InheritedTypeSyntax(\(node)))")
#endif

        print("node.type.children(viewMode: .fixedUp)")
        dump(node.type.children(viewMode: .fixedUp))

        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let trailingOffset = node.type.trimmedByteRange.endOffset - 1

        inheritOffsets.append(trailingOffset)

        return .visitChildren
    }
}
