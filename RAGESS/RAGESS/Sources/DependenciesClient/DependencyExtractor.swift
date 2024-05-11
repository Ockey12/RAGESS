//
//  DependencyExtractor.swift
//
//  
//  Created by Ockey12 on 2024/05/11
//  
//

import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

struct DependencyExtractor {
//    func extract() -> [any DeclarationObject] {
//        
//    }

    func extractOffset(from sourceFile: SourceFile) -> [Int] {
        let parsedFile = Parser.parse(source: sourceFile.content)
#if DEBUG
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
        print(#function)
        print("PATH: \(sourceFile.path)")
        print(parsedFile.debugDescription)
#endif

        let visitor = Visitor(
            locationConverter: SourceLocationConverter(
                fileName: sourceFile.path,
                tree: parsedFile
            )
        )
        visitor.walk(Syntax(parsedFile))

#if DEBUG
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
#endif

        return visitor.getOffsets()
    }
}
