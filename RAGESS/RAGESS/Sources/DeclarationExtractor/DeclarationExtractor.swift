//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import DeclaredObject
import Dependencies
import Foundation
import SourceKitClient
import SwiftIndexStoreClient
import SwiftIndexStoreObject
import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

public enum DeclarationExtractor {
    public struct Response {
        public let rootDirectory: Directory
        public let usrTable: USRTable
        public let sourceFileTable: [String: WritableKeyPath<Directory, SourceFile>]
        public let indexStoreObjects: [IndexStoreObject]
    }

    public static func extractDeclarations(
        rootDirectory: Directory,
        indexStoreURL: URL
    ) throws -> Response {
        @Dependency(SwiftIndexStoreClient.self) var swiftIndexStoreClient
        let indexStoreObjects = try swiftIndexStoreClient.extractOccurrences(
            indexStoreURL: indexStoreURL,
            projectRootPath: rootDirectory.fullPath
        )

        // Assign USR to the DeclaredObject of each SourceFile in the SourceFileTable.
        let definitions = indexStoreObjects.filter { $0.role == .definition }
        var sourceFilesTable = extractDeclarations(directory: rootDirectory)
        var usrTable = USRTable()
        for object in definitions {
            usrTable.merge(assignUSR(indexStoreObject: object, sourceFileTable: &sourceFilesTable)) { current, _ in
                current
            }
        }

        var resultRootDirectory = rootDirectory
        for (_, sourceFile) in sourceFilesTable {
            resultRootDirectory[keyPath: sourceFile.keyPathFromRootDirectory] = sourceFile
        }

        let sourceFileKeyPathTable = sourceFilesTable.mapValues { $0.keyPathFromRootDirectory }

        return Response(
            rootDirectory: resultRootDirectory,
            usrTable: usrTable,
            sourceFileTable: sourceFileKeyPathTable,
            indexStoreObjects: indexStoreObjects
        )
    }

    private static func extractDeclarations(directory: Directory) -> SourceFileTable {
        var sourceFilesTable = SourceFileTable()

        for sourceFile in directory.files {
            let fileWithAddedObjects = extractDeclarations(sourceFile: sourceFile)
            sourceFilesTable[fileWithAddedObjects.fullPath] = fileWithAddedObjects
        }

        for subDirectory in directory.subDirectories {
            sourceFilesTable.merge(extractDeclarations(directory: subDirectory)) { current, _ in
                current
            }
        }

        return sourceFilesTable
    }

    private static func extractDeclarations(sourceFile: SourceFile) -> SourceFile {
        let parsedFile = Parser.parse(source: sourceFile.sourceCode)
        let visitor = DeclarationVisitor(
            in: sourceFile.fullPath,
            locatonConverter: SourceLocationConverter(
                fileName: sourceFile.fullPath,
                tree: parsedFile
            )
        )

        visitor.walk(Syntax(parsedFile))

        var result = sourceFile
        result.declaredObjects = visitor.extractedDeclarations

        return result
    }

    private static func assignUSR(indexStoreObject: IndexStoreObject, sourceFileTable: inout [FullPath: SourceFile]) -> USRTable {
        guard indexStoreObject.role == .definition,
              let sourceFile = sourceFileTable[indexStoreObject.fullPath]
        else {
            return [:]
        }

        var resultFile = sourceFile
        var usrTable = USRTable()
        for (index, object) in sourceFile.declaredObjects.enumerated() {
            if object.rangeInXcode.contains(indexStoreObject.locationInXcode) {
                let fromRootDirectory = assignUSR(
                    usr: indexStoreObject.usr,
                    definitionLocation: indexStoreObject.locationInXcode,
                    declaredObject: &resultFile.declaredObjects[index],
                    fromRootDirectory: resultFile.keyPathFromRootDirectory.appending(path: \.declaredObjects[index])
                )
                usrTable[indexStoreObject.usr] = fromRootDirectory
                break
            }
        }

        sourceFileTable[indexStoreObject.fullPath] = resultFile

        return usrTable
    }

    private static func assignUSR(
        usr: String,
        definitionLocation: LocationInXcode,
        declaredObject: inout DeclaredObject,
        fromRootDirectory: WritableKeyPath<Directory, DeclaredObject>
    ) -> WritableKeyPath<Directory, DeclaredObject> {
        // Search from the kind that is most likely to meet the conditions.

        for (index, variableObject) in declaredObject.variables.enumerated() {
            if variableObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.variables[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.variables[index])
                )
            }
        }

        for (index, functionObject) in declaredObject.functions.enumerated() {
            if functionObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.functions[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.functions[index])
                )
            }
        }

        for (index, initializerObject) in declaredObject.initializers.enumerated() {
            if initializerObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.initializers[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.initializers[index])
                )
            }
        }

        for (index, caseObject) in declaredObject.cases.enumerated() {
            if caseObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.cases[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.cases[index])
                )
            }
        }

        for (index, enumObject) in declaredObject.nestingEnums.enumerated() {
            if enumObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.nestingEnums[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.nestingEnums[index])
                )
            }
        }

        for (index, structObject) in declaredObject.nestingStructs.enumerated() {
            if structObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.nestingStructs[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.nestingStructs[index])
                )
            }
        }

        for (index, classObject) in declaredObject.nestingClasses.enumerated() {
            if classObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.nestingClasses[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.nestingClasses[index])
                )
            }
        }

        for (index, actorObject) in declaredObject.nestingActors.enumerated() {
            if actorObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.nestingActors[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.nestingActors[index])
                )
            }
        }

        for (index, protocolObject) in declaredObject.nestingProtocols.enumerated() {
            if protocolObject.rangeInXcode.contains(definitionLocation) {
                return assignUSR(
                    usr: usr,
                    definitionLocation: definitionLocation,
                    declaredObject: &declaredObject.nestingProtocols[index],
                    fromRootDirectory: fromRootDirectory.appending(path: \.nestingProtocols[index])
                )
            }
        }

        declaredObject.usrs.append(usr)

        return fromRootDirectory
    }
}

private extension String {
    var removedTags: String {
        var decl = self
        while let startIndex = decl.firstIndex(of: "<"),
              let endIndex = decl[startIndex...].firstIndex(of: ">") {
            decl.removeSubrange(startIndex ... endIndex)
        }

        decl = decl.replacingOccurrences(of: "&gt;", with: ">")
        decl = decl.replacingOccurrences(of: "&lt;", with: "<")

        return decl
    }
}
