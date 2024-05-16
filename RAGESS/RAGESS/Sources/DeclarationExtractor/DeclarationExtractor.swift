//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

public struct DeclarationExtractor {
    public init() {}

    public func extractDeclarations(from sourceFile: SourceFile) -> [any DeclarationObject] {
        let parsedFile = Parser.parse(source: sourceFile.content)

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
            print("PATH: \(sourceFile.path)")
            print(parsedFile.debugDescription)
        #endif

        let visitor = DeclarationVisitor(
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

        var result: [any DeclarationObject] = []
        result.append(contentsOf: visitor.getStructDeclarations())
        result.append(contentsOf: visitor.getClassDeclarations())
        result.append(contentsOf: visitor.getEnumDeclarations())
        result.append(contentsOf: visitor.getVariableDeclarations())
        result.append(contentsOf: visitor.getFunctionDeclarations())

        return result
    }
}
