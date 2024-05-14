//
//  DependencyExtractor.swift
//
//
//  Created by Ockey12 on 2024/05/11
//
//

import Dependencies
import LanguageServerProtocol
import SourceKitClient
import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

struct DependencyExtractor {
    func extract(
        declarationObjects: inout [DeclarationObject],
        allSourceFiles: [SourceFile],
        buildSettings: [String: String],
        packages: [PackageObject]
    ) async {
        print("\(#filePath) - \(#function)")
        
        let allSourceFilePaths = allSourceFiles.map { $0.path }
        print("--- allSourceFilePaths ---")
        for path in allSourceFilePaths {
            print("    \(path)")
        }

        print("--- packages ---")
        dump(packages)

        for sourceFile in allSourceFiles {
            let generator = CompilerArgumentsGenerator(
                targetFilePath: sourceFile.path,
                buildSettings: buildSettings,
                sourceFilePaths: allSourceFilePaths,
                packages: packages
            )

            guard let arguments = try? await generator.generateArguments() else {
                print("\(#filePath) - \(#function)")
                print("ERROR: Cannot generate compiler arguments about \(sourceFile.path).\n")
                continue
            }
            await extractDependencies(
                from: sourceFile,
                declarationObjects: &declarationObjects,
                allSourceFilePaths: allSourceFilePaths,
                sourceKitArguments: arguments
            )
        }
    }

    private func extractDependencies(
        from sourceFile: SourceFile,
        declarationObjects: inout [DeclarationObject],
        allSourceFilePaths: [String],
        sourceKitArguments: [String]
    ) async {
        let callerOffsets = extractCallerOffsets(from: sourceFile)

        #if DEBUG
        print("\(#filePath) - \(#function)")
        print("from \(sourceFile.path)")
        #endif

        @Dependency(SourceKitClient.self) var sourceKitClient
        for callerOffset in callerOffsets {
            print("callerOffset: \(callerOffset)")
            do {
                let response = try await sourceKitClient.sendCursorInfoRequest(
                    file: sourceFile.path,
                    offset: callerOffset,
                    sourceFilePaths: allSourceFilePaths,
                    arguments: sourceKitArguments
                )
                #if DEBUG
//                    print("\(#filePath) - \(#function)")
                    print("sourceKitClient.sendCursorInfoRequest")
//                    dump(response)
                #endif

                guard let definitionFilePath = response[CursorInfoResponseKeys.filePath.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.filepath`.")
                    continue
                }
                print("definitionFilePath: \(definitionFilePath)")

                guard let definitionLine = response[CursorInfoResponseKeys.line.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.line`.")
                    continue
                }
                print("definitionLine: \(definitionLine)")

                guard let definitionColumn = response[CursorInfoResponseKeys.column.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.column`.")
                    continue
                }
                print("definitionColumn: \(definitionColumn)")

                guard let definitionOffset = response[CursorInfoResponseKeys.offset.key] else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.offset`.")
                    continue
                }
                print("definitionOffset: \(definitionOffset)")

//                let definitionPosition = SourcePosition(line: definitionLine, utf8index: definitionColumn)
//                guard let definitionObjectIndex = declarationObjects.firstIndex(where: {
//                    $0.fullPath == definitionFilePath
//                        && $0.positionRange.contains(definitionPosition)
//                }) else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find definition object in [\(DeclarationObject)].")
//                    continue
//                }
//                guard let callerIndex = declarationObjects.firstIndex(where: {
//                    $0.fullPath == sourceFile.path
//                    // TODO: Collate offsets.
//                }) else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [DeclarationObject].")
//                    continue
//                }
//                var callerIndexes = declarationObjects.enumerated().compactMap{ (index, element) -> Int? in
//                    if element.fullPath == sourceFile.path && element.offsetRange.contains(callerOffset) {
//                        return index
//                    }
//                    return nil
//                }
//                guard var callerIndex = callerIndexes.first else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [\(DeclarationObject)].")
//                    continue
//                }
//                callerIndexes = callerIndexes.dropFirst()
//                for index in callerIndexes {
//                    if (callerOffset - declarationObjects[index].offsetRange.lowerBound)
//                        < (callerOffset - declarationObjects[callerIndex].offsetRange.lowerBound) {
//                        callerIndex = index
//                    }
//                }
//                let callerObject = declarationObjects[callerIndex]
//                let definitionObject = declarationObjects[definitionObjectIndex]
//                let dependency = DependencyObject(
//                    dependingObject: .init(kind: <#T##DependencyObject.Object.Kind#>, filePath: callerObject.fullPath, offset: callerOffset),
//                    dependedObject: .init(kind: <#T##DependencyObject.Object.Kind#>, filePath: definitionObject.fullPath, offset: definitionOffset)
//                )
                print()
            } catch {
                print("ERROR in \(#filePath) - \(#function): \(error)")
            }
        }
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
