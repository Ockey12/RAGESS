//
//  TypeDeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

public struct TypeDeclarationExtractor {
    public init() {}

    public func extractTypeDeclarations(from sourceFile: SourceFile) -> [any TypeDeclaration] {
        let parsedFile = Parser.parse(source: sourceFile.content)

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
            print("PATH: \(sourceFile.path)")
            print(parsedFile.debugDescription)
        #endif

        let visitor = TypeDeclVisitor(
            in: sourceFile.path,
            locatonConverter: SourceLocationConverter(
                fileName: sourceFile.path,
                tree: parsedFile
            )
        )
        visitor.walk(Syntax(parsedFile))

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
        #endif

        var result: [any TypeDeclaration] = []
        result.append(contentsOf: visitor.getStructDeclarations())
        result.append(contentsOf: visitor.getClassDeclarations())

        return result
    }
}
