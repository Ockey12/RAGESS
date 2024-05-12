//
//  DependencyExtractor.swift
//
//
//  Created by Ockey12 on 2024/05/11
//
//

import Dependencies
import Dependency
import LanguageServerProtocol
import SourceKitClient
import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

enum DependencyExtractor {
//    func extract() -> [any DeclarationObject] {
//
//    }

    func extractDependencies(
        from sourceFile: SourceFile,
        declarationObjects: [DeclarationObject],
        sourceFilePaths: [String],
        sourceKitArguments: [String]
    ) -> [DeclarationObject] {
        var objects = declarationObjects
        let callerOffsets = extractCallerOffsets(from: sourceFile)

        @Dependency(SourceKitClient.self) var sourceKitClient
        for callerOffset in callerOffsets {
            do {
                let response = try await sourceKitClient.sendCursorInfoRequest(
                    file: sourceFile.path,
                    offset: callerOffset,
                    sourceFilePaths: sourceFilePaths,
                    arguments: sourceKitArguments
                )
                #if DEBUG
                    print("\(#filePath) - \(#function)")
                    dump(response)
                #endif

                guard let definitionFilePath = response[CursorInfoResponseKeys.filePath.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.filepath`.")
                    continue
                }
                guard let definitionLine = response[CursorInfoResponseKeys.line.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.line`.")
                    continue
                }
                guard let definitionColumn = response[CursorInfoResponseKeys.column.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.column`.")
                    continue
                }
                guard let definitionOffset = response[CursorInfoResponseKeys.offset.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.offset`.")
                    continue
                }

                let definitionPosition = SourcePosition(line: definitionLine, utf8index: definitionColumn)
                guard let definitionObjectIndex = declarationObjects.firstIndex(where: {
                    $0.fullPath == definitionFilePath
                        && $0.positionRange.contains(definitionPosition)
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find definition object in [\(DeclarationObject)].")
                    continue
                }
//                guard let callerIndex = declarationObjects.firstIndex(where: {
//                    $0.fullPath == sourceFile.path
//                    // TODO: Collate offsets.
//                }) else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [DeclarationObject].")
//                    continue
//                }
                let callerIndexes = declarationObjects.enumerated().compactMap{ (index, element) -> Int? in
                    if element.fullPath == sourceFile.path && element.offsetRange.contains(callerOffset) {
                        return index
                    }
                    return nil
                }
                guard var callerIndex = callerIndexes.first else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [\(DeclarationObject)].")
                    continue
                }
                callerIndexes = callerIndexes.dropFirst()
                for index in callerIndexes {
                    if (callerOffset - declarationObjects[index].offsetRange.lowerBound)
                        < (callerOffset - declarationObjects[callerIndex].offsetRange.lowerBound) {
                        callerIndex = index
                    }
                }
                let caller = declarationObjects[callerIndex]
//                let dependency = depende
            } catch {
                print("ERROR in \(#filePath) - \(#function): \(error)")
            }
        }

        return objects
    }

    func extractCallerOffsets(from sourceFile: SourceFile) -> [Int] {
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
