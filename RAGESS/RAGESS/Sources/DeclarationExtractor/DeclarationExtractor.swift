//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import Dependencies
import Foundation
import SourceKitClient
import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

public enum DeclarationExtractor {
    public static func extractDeclarations(
        from sourceFiles: [SourceFile],
        buildSettings: [String: String],
        packages: [PackageObject]
    ) async -> [DeclaredObject] {
        var objects = [DeclaredObject]()

        // Extract data objects from all source files.
        for sourceFile in sourceFiles {
            let parsedFile = Parser.parse(source: sourceFile.content)
            let visitor = DeclarationVisitor(
                in: sourceFile.path,
                locatonConverter: SourceLocationConverter(
                    fileName: sourceFile.path,
                    tree: parsedFile
                )
            )
            visitor.walk(Syntax(parsedFile))
            objects.append(contentsOf: visitor.extractedDeclarations)
        }

        var flattenedObjects = [SourceKitRequestObject]()

        for object in objects {
            flattenedObjects.append(
                contentsOf: flatMap(
                    in: object,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFiles.map {
                        $0.path
                    },
                    packages: packages
                )
            )
        }

        @Dependency(SourceKitClient.self) var sourceKitClient
//        do {
//            let responses = try await sourceKitClient.sendParallelCursorInfoRequest(
//                requestObjects: flattenedObjects,
//                allSourceFiles: sourceFiles
//            )
//
//            for response in responses {
//                guard let rootIndex = objects.firstIndex(where: { $0.id == response.request.rootObjectID }) else {
//                    print("ERROR: \(#file) - \(#function): Cannot find root object of  \(response.request.object.name).")
//                    continue
//                }
//                guard let annotatedDecl = response.response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
//                    print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(response.request.object.name).")
//                    continue
//                }
//
//                var annotatedObject = objects[rootIndex][keyPath: response.request.keyPathForRootObject]
//                annotatedObject.annotatedDecl = annotatedDecl
//
//                objects[rootIndex][keyPath: response.request.keyPathForRootObject] = annotatedObject
//            }
//        } catch {
//            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration.")
//            print(error)
//        }
        let responses = await sourceKitClient.sendParallelCursorInfoRequest(
            requestObjects: flattenedObjects,
            allSourceFiles: sourceFiles
        )

        for response in responses {
            guard let rootIndex = objects.firstIndex(where: { $0.id == response.request.rootObjectID }) else {
                print("ERROR: \(#file) - \(#function): Cannot find root object of  \(response.request.object.name).")
                continue
            }
            guard let annotatedDecl = response.response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(response.request.object.name).")
                continue
            }

            var annotatedObject = objects[rootIndex][keyPath: response.request.keyPathForRootObject]
            annotatedObject.annotatedDecl = annotatedDecl

            objects[rootIndex][keyPath: response.request.keyPathForRootObject] = annotatedObject
        }

        return objects
    }

    private static func flatMap(
        in object: DeclaredObject,
        rootObjectID: UUID? = nil,
        parentKeyPathForRootObject: WritableKeyPath<DeclaredObject, DeclaredObject>? = nil,
        index: Int? = nil,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) -> [SourceKitRequestObject] {
        let keyPathForRootObject: WritableKeyPath<DeclaredObject, DeclaredObject>

        if let rootObjectID,
           let parentKeyPathForRootObject,
           let index {
            switch object.kind {
            case .struct:
                let partialKeyPath = \DeclaredObject.nestingStructs[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .class:
                let partialKeyPath = \DeclaredObject.nestingClasses[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .enum:
                let partialKeyPath = \DeclaredObject.nestingEnums[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .protocol:
                let partialKeyPath = \DeclaredObject.nestingProtocols[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .actor:
                let partialKeyPath = \DeclaredObject.nestingActors[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .initializer:
                let partialKeyPath = \DeclaredObject.initializers[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .variable:
                let partialKeyPath = \DeclaredObject.variables[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .function:
                let partialKeyPath = \DeclaredObject.functions[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            case .case:
                let partialKeyPath = \DeclaredObject.cases[index]
                keyPathForRootObject = parentKeyPathForRootObject.appending(path: partialKeyPath)
            }
        } else {
            // If both parameters are nil, this object is the highest-level parent object.
            keyPathForRootObject = \DeclaredObject.self
        }

        var result: [SourceKitRequestObject] = [.init(
            rootObjectID: rootObjectID ?? object.id,
            keyPathForRootObject: keyPathForRootObject,
            object: object,
            argumentsGenerator: .init(
                targetFilePath: object.fullPath,
                buildSettings: buildSettings,
                sourceFilePaths: sourceFilePaths,
                packages: packages
            )
        )]

        for (index, variableObject) in object.variables.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: variableObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, functionObject) in object.functions.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: functionObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, initializerObject) in object.initializers.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: initializerObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, structObject) in object.nestingStructs.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: structObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, classObject) in object.nestingClasses.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: classObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, enumObject) in object.nestingEnums.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: enumObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, protocolObject) in object.nestingProtocols.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: protocolObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, actorObject) in object.nestingActors.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: actorObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        for (index, caseObject) in object.cases.enumerated() {
            result.append(
                contentsOf: flatMap(
                    in: caseObject,
                    rootObjectID: rootObjectID ?? object.id,
                    parentKeyPathForRootObject: keyPathForRootObject,
                    index: index,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
            )
        }

        return result
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
