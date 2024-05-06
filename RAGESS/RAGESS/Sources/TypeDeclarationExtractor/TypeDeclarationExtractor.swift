//
//  TypeDeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import TypeDeclaration
import SwiftParser
import SwiftSyntax
import XcodeObject

public struct TypeDeclarationExtractor {
    public init() {}

    public func extractStructureDeclarations(from sourceFile: SourceFile) -> [StructObject] {
        let parsedFile = Parser.parse(source: sourceFile.content)

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
            print("PATH: \(sourceFile.path)")
            print(parsedFile.debugDescription)
        #endif

        let visitor = TypeDeclVisitor(
            locatonConverter: SourceLocationConverter(
                fileName: sourceFile.path,
                tree: parsedFile
            )
        )
        visitor.walk(Syntax(parsedFile))

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
        #endif

        return visitor.getStructDeclarations().map { type in
            var declarationType = type
            declarationType.fullPath = sourceFile.path
            return declarationType
        }
    }
}
