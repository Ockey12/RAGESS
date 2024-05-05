//
//  TypeDeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import DeclarationType
import SwiftParser
import SwiftSyntax
import XcodeObject

public struct TypeDeclarationExtractor {
    public init() {}

    public func extract(from sourceFile: SourceFile) -> [DeclarationType] {
        let parsedFile = Parser.parse(source: sourceFile.content)

        #if DEBUG
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
            print("PATH: \(sourceFile.path)")
            print(parsedFile.debugDescription)
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
        #endif

        let visitor = TokenVisitor(
            locatonConverter: SourceLocationConverter(
                fileName: sourceFile.path,
                tree: parsedFile
            )
        )

        _ = visitor.rewrite(Syntax(parsedFile))

        return []
    }
}
