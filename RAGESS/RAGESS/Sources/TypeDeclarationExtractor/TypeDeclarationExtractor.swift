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
        #endif

//        let rewriter = Rewriter(
//            locatonConverter: SourceLocationConverter(
//                fileName: sourceFile.path,
//                tree: parsedFile
//            )
//        )
//
//        _ = rewriter.rewrite(Syntax(parsedFile))

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

        return visitor.getDeclarationTypes().map { type in
            var declarationType = type
            declarationType.fullPath = sourceFile.path
            return declarationType
        }
    }
}
