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

public struct DeclarationExtractor {
    public init() {}

    public func extractDeclarations(
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
        do {
            let responses = try await sourceKitClient.sendParallelCursorInfoRequest(
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
//                guard var annotatedObject = objects[rootIndex][keyPath: response.request.keyPathForRootObject] else {
//                    print("ERROR: \(#file) - \(#function): Cannot cast \(response.request.object.name) to any DeclarationObject.")
//                    continue
//                }
//                guard let keyPath = response.request.keyPathForRootObject as? WritableKeyPath<any DeclarationObject, any DeclarationObject> else {
//                    print("ERROR: \(#file) - \(#function): Cannot cast \(response.request.object.name).keyPathForRootObject to WritableKeyPath<any DeclarationObject, any DeclarationObject>.")
//                    continue
//                }

                var annotatedObject = objects[rootIndex][keyPath: response.request.keyPathForRootObject]
                annotatedObject.annotatedDecl = annotatedDecl

                objects[rootIndex][keyPath: response.request.keyPathForRootObject] = annotatedObject
            }
        } catch {
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration.")
            print(error)
        }

        return objects

        func flatMap(
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
               let index
            {
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

//                switch object {
//                case let structObject as StructObject:
//                    let partialKeyPath: PartialKeyPath<any TypeNestable> = \.nestingStructs[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case let classObject as ClassObject:
//                    let partialKeyPath: PartialKeyPath<any TypeNestable> = \.nestingClasses[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    keyPathForRootObject = keyPath
//
//                case let enumObject as EnumObject:
//                    let partialKeyPath: PartialKeyPath<any TypeNestable> = \.nestingEnums[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case is EnumObject.CaseObject:
//                    let partialKeyPath: PartialKeyPath<any HasCases> = \.cases[index]
//                    let partialKeyPath = \EnumObject.cases[index]
//                    let path = parentKeyPathForRootObject as KeyPath<any DeclarationObject, EnumObject>
//                    guard let enumKeyPath = parentKeyPathForRootObject as? PartialKeyPath<EnumObject> else {
//                        fatalError()
//                    }
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//                    keyPathForRootObject = parentKeyPathForRootObject

//                case let protocolObject as ProtocolObject:
//                    let partialKeyPath: PartialKeyPath<any TypeNestable> = \.nestingProtocols[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case let actorObject as ActorObject:
//                    let partialKeyPath: PartialKeyPath<any TypeNestable> = \.nestingActors[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case let initializerObject as InitializerObject:
//                    let partialKeyPath: PartialKeyPath<any Initializable> = \.initializers[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case let variableObject as VariableObject:
//                    let partialKeyPath: PartialKeyPath<any DeclarationObject> = \.variables[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                case let functionObject as FunctionObject:
//                    let partialKeyPath: PartialKeyPath<any DeclarationObject> = \.functions[index]
//                    guard let keyPath = parentKeyPathForRootObject.appending(path: partialKeyPath) else {
//                        fatalError()
//                    }
//                    print("KeyPath synthesis was successful")
//                    print("    parentKeyPathForRootObject: \(parentKeyPathForRootObject)")
//                    print("    partialKeyPath: \(partialKeyPath)\n")
//                    keyPathForRootObject = keyPath
//
//                default:
//                    fatalError()
//                }
            } else {
                // If both parameters are nil, this object is the highest-level parent object.
                keyPathForRootObject = \DeclaredObject.self
//                switch object {
//                case is StructObject:
//                    keyPathForRootObject = \StructObject.self
//                case is ClassObject:
//                    keyPathForRootObject = \ClassObject.self
//                case is EnumObject:
//                    keyPathForRootObject = \EnumObject.self
//                case is ProtocolObject:
//                    keyPathForRootObject = \ProtocolObject.self
//                case is ActorObject:
//                    keyPathForRootObject = \ActorObject.self
//                case is InitializerObject:
//                    keyPathForRootObject = \InitializerObject.self
//                case is VariableObject:
//                    keyPathForRootObject = \VariableObject.self
//                case is FunctionObject:
//                    keyPathForRootObject = \FunctionObject.self
//                default:
//                    fatalError()
//                }
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
                        buildSettings: buildSettings,
                        sourceFilePaths: sourceFilePaths,
                        packages: packages
                    )
                )
            }

//            if let initializableObject = object as? any Initializable {
//                for (index, initializerObject) in initializableObject.initializers.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: initializerObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//            }

//            if let typeNestableObject = object as? any TypeNestable {
//                for (index, structObject) in typeNestableObject.nestingStructs.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: structObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//                for (index, classObject) in typeNestableObject.nestingClasses.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: classObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//                for (index, enumObject) in typeNestableObject.nestingEnums.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: enumObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//                for (index, protocolObject) in typeNestableObject.nestingProtocols.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: protocolObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//                for (index, actorObject) in typeNestableObject.nestingActors.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: actorObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//            }

//            if let enumObject = object as? EnumObject {
//                for (index, caseObject) in enumObject.cases.enumerated() {
//                    result.append(
//                        contentsOf: flatMap(
//                            in: caseObject,
//                            rootObjectID: rootObjectID ?? object.id,
//                            parentKeyPathForRootObject: keyPathForRootObject,
//                            index: index,
//                            buildSettings: buildSettings,
//                            sourceFilePaths: sourceFilePaths,
//                            packages: packages
//                        )
//                    )
//                }
//            }

            return result
        }
    }

//    public func extractDeclarations(
//        from sourceFile: SourceFile,
//        buildSettings: [String: String],
//        sourceFilePaths: [String],
//        packages: [PackageObject]
//    ) async -> [any DeclarationObject] {
//        let parsedFile = Parser.parse(source: sourceFile.content)
//
//        #if DEBUG
//            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
//            print("PATH: \(sourceFile.path)")
//            print(parsedFile.debugDescription)
//        #endif
//
//        let visitor = DeclarationVisitor(
//            in: sourceFile.path,
//            locatonConverter: SourceLocationConverter(
//                fileName: sourceFile.path,
//                tree: parsedFile
//            )
//        )
//        visitor.walk(Syntax(parsedFile))
//
//        #if DEBUG
//            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
//        #endif
//
//        var result: [any DeclarationObject] = visitor.extractedDeclarations
//
//        for (index, object) in result.enumerated() {
//            if let enumObject = object as? EnumObject {
//                let annotatedEnumObject = await getAnnotatedDeclaration(
//                    enumObject,
//                    buildSettings: buildSettings,
//                    sourceFilePaths: sourceFilePaths,
//                    packages: packages
//                )
//                result[index] = annotatedEnumObject
//
//            } else if let typeObject = object as? any TypeDeclaration {
//                let annotatedTypeObject = await getAnnotatedDeclaration(
//                    typeObject,
//                    buildSettings: buildSettings,
//                    sourceFilePaths: sourceFilePaths,
//                    packages: packages
//                )
//                result[index] = annotatedTypeObject
//
//            } else if let typeNestableObject = object as? any TypeNestable {
//                let annotatedTypeNestableObject = await getAnnotatedDeclaration(
//                    typeNestableObject,
//                    buildSettings: buildSettings,
//                    sourceFilePaths: sourceFilePaths,
//                    packages: packages
//                )
//                result[index] = annotatedTypeNestableObject
//
//            } else if let protocolObject = object as? ProtocolObject {
//                let annotatedProtocolObject = await getAnnotatedDeclaration(
//                    protocolObject,
//                    buildSettings: buildSettings,
//                    sourceFilePaths: sourceFilePaths,
//                    packages: packages
//                )
//                result[index] = annotatedProtocolObject
//
//            } else {
//                print("WARNING: \(#file) - \(#function): \(object.name) cannot be applied to any generic `getAnnotatedDeclaration` function.")
//            }
//        }
//
//        return result
//    }

    // Used for `StructObject`, `ClassObject`, `ActorObject`.
    private func getAnnotatedDeclaration<T: TypeDeclaration>(
        _ typeObject: T,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> T {
        @Dependency(SourceKitClient.self) var sourceKitClient
        let argumentsGenerator = CompilerArgumentsGenerator(
            targetFilePath: typeObject.fullPath,
            buildSettings: buildSettings,
            sourceFilePaths: sourceFilePaths,
            packages: packages
        )

        do {
            let arguments = try argumentsGenerator.generateArguments()
            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: typeObject.fullPath,
                offset: typeObject.nameOffset,
                sourceFilePaths: sourceFilePaths,
                arguments: arguments
            )

            guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(typeObject.name).")
                return typeObject
            }

            var resultObject = typeObject
            resultObject.annotatedDecl = annotatedDecl.removedTags

            for (index, initializer) in typeObject.initializers.enumerated() {
                let annotatedInit = await getAnnotatedDeclaration(
                    initializer,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.initializers[index] = annotatedInit
            }

            for (index, variable) in typeObject.variables.enumerated() {
                let annotatedVariable = await getAnnotatedDeclaration(
                    variable,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.variables[index] = annotatedVariable
            }

            for (index, function) in typeObject.functions.enumerated() {
                let annotatedFunction = await getAnnotatedDeclaration(
                    function,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.functions[index] = annotatedFunction
            }

            for (index, nestingProtocol) in resultObject.nestingProtocols.enumerated() {
                let annotatedProtocol = await getAnnotatedDeclaration(
                    nestingProtocol,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingProtocols[index] = annotatedProtocol
            }

            for (index, nestingStruct) in resultObject.nestingStructs.enumerated() {
                let annotatedStruct = await getAnnotatedDeclaration(
                    nestingStruct,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingStructs[index] = annotatedStruct
            }

            for (index, nestingClass) in resultObject.nestingClasses.enumerated() {
                let annotatedClass = await getAnnotatedDeclaration(
                    nestingClass,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingClasses[index] = annotatedClass
            }

            for (index, nestingEnum) in resultObject.nestingEnums.enumerated() {
                let annotatedEnum = await getAnnotatedDeclaration(
                    nestingEnum,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingEnums[index] = annotatedEnum
            }

            return resultObject
        } catch {
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration about \(typeObject.name).")
            print(error)
            return typeObject
        }
    }

    // Used for `EnumObject`.
    private func getAnnotatedDeclaration(
        _ enumObject: EnumObject,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> EnumObject {
        @Dependency(SourceKitClient.self) var sourceKitClient
        let argumentsGenerator = CompilerArgumentsGenerator(
            targetFilePath: enumObject.fullPath,
            buildSettings: buildSettings,
            sourceFilePaths: sourceFilePaths,
            packages: packages
        )

        do {
            let arguments = try argumentsGenerator.generateArguments()
            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: enumObject.fullPath,
                offset: enumObject.nameOffset,
                sourceFilePaths: sourceFilePaths,
                arguments: arguments
            )

            guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(enumObject.name).")
                return enumObject
            }

            var resultObject = enumObject
            resultObject.annotatedDecl = annotatedDecl.removedTags

            for (index, initializer) in enumObject.initializers.enumerated() {
                let annotatedInit = await getAnnotatedDeclaration(
                    initializer,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.initializers[index] = annotatedInit
            }

            for (index, variable) in enumObject.variables.enumerated() {
                let annotatedVariable = await getAnnotatedDeclaration(
                    variable,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.variables[index] = annotatedVariable
            }

            for (index, function) in enumObject.functions.enumerated() {
                let annotatedFunction = await getAnnotatedDeclaration(
                    function,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.functions[index] = annotatedFunction
            }

            for (index, nestingProtocol) in resultObject.nestingProtocols.enumerated() {
                let annotatedProtocol = await getAnnotatedDeclaration(
                    nestingProtocol,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingProtocols[index] = annotatedProtocol
            }

            for (index, nestingStruct) in resultObject.nestingStructs.enumerated() {
                let annotatedStruct = await getAnnotatedDeclaration(
                    nestingStruct,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingStructs[index] = annotatedStruct
            }

            for (index, nestingClass) in resultObject.nestingClasses.enumerated() {
                let annotatedClass = await getAnnotatedDeclaration(
                    nestingClass,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingClasses[index] = annotatedClass
            }

            for (index, nestingEnum) in resultObject.nestingEnums.enumerated() {
                let annotatedEnum = await getAnnotatedDeclaration(
                    nestingEnum,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingEnums[index] = annotatedEnum
            }

            for (index, caseObject) in resultObject.cases.enumerated() {
                let response = try await sourceKitClient.sendCursorInfoRequest(
                    file: caseObject.fullPath,
                    offset: caseObject.nameOffset,
                    sourceFilePaths: sourceFilePaths,
                    arguments: arguments
                )

                guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                    print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(resultObject.name).cases[\(index)].")
                    continue
                }

                resultObject.cases[index].annotatedDecl = annotatedDecl.removedTags
            }

            return resultObject
        } catch {
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration about \(enumObject.name).")
            print(error)
            return enumObject
        }
    }

    // Used for `InitializerObject`, `VariableObject`, `FunctionObject`.
    private func getAnnotatedDeclaration<T: TypeNestable>(
        _ typeNestableObject: T,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> T {
        @Dependency(SourceKitClient.self) var sourceKitClient
        let argumentsGenerator = CompilerArgumentsGenerator(
            targetFilePath: typeNestableObject.fullPath,
            buildSettings: buildSettings,
            sourceFilePaths: sourceFilePaths,
            packages: packages
        )

        do {
            let arguments = try argumentsGenerator.generateArguments()
            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: typeNestableObject.fullPath,
                offset: typeNestableObject.nameOffset,
                sourceFilePaths: sourceFilePaths,
                arguments: arguments
            )

            guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(typeNestableObject.name).")
                return typeNestableObject
            }

            var resultObject = typeNestableObject
            resultObject.annotatedDecl = annotatedDecl.removedTags

            for (index, variable) in typeNestableObject.variables.enumerated() {
                let annotatedVariable = await getAnnotatedDeclaration(
                    variable,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.variables[index] = annotatedVariable
            }

            for (index, function) in typeNestableObject.functions.enumerated() {
                let annotatedFunction = await getAnnotatedDeclaration(
                    function,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.functions[index] = annotatedFunction
            }

            for (index, nestingProtocol) in resultObject.nestingProtocols.enumerated() {
                let annotatedProtocol = await getAnnotatedDeclaration(
                    nestingProtocol,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingProtocols[index] = annotatedProtocol
            }

            for (index, nestingStruct) in resultObject.nestingStructs.enumerated() {
                let annotatedStruct = await getAnnotatedDeclaration(
                    nestingStruct,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingStructs[index] = annotatedStruct
            }

            for (index, nestingClass) in resultObject.nestingClasses.enumerated() {
                let annotatedClass = await getAnnotatedDeclaration(
                    nestingClass,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingClasses[index] = annotatedClass
            }

            for (index, nestingEnum) in resultObject.nestingEnums.enumerated() {
                let annotatedEnum = await getAnnotatedDeclaration(
                    nestingEnum,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.nestingEnums[index] = annotatedEnum
            }

            return resultObject
        } catch {
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration about \(typeNestableObject.name).")
            print(error)
            return typeNestableObject
        }
    }

    private func getAnnotatedDeclaration(
        _ protocolObject: ProtocolObject,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> ProtocolObject {
        @Dependency(SourceKitClient.self) var sourceKitClient
        let argumentsGenerator = CompilerArgumentsGenerator(
            targetFilePath: protocolObject.fullPath,
            buildSettings: buildSettings,
            sourceFilePaths: sourceFilePaths,
            packages: packages
        )

        do {
            let arguments = try argumentsGenerator.generateArguments()
            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: protocolObject.fullPath,
                offset: protocolObject.nameOffset,
                sourceFilePaths: sourceFilePaths,
                arguments: arguments
            )

            guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(protocolObject.name).")
                return protocolObject
            }

            var resultObject = protocolObject
            resultObject.annotatedDecl = annotatedDecl.removedTags

            for (index, initializer) in protocolObject.initializers.enumerated() {
                let annotatedInit = await getAnnotatedDeclaration(
                    initializer,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.initializers[index] = annotatedInit
            }

            for (index, variable) in protocolObject.variables.enumerated() {
                let annotatedVariable = await getAnnotatedDeclaration(
                    variable,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.variables[index] = annotatedVariable
            }

            for (index, function) in protocolObject.functions.enumerated() {
                let annotatedFunction = await getAnnotatedDeclaration(
                    function,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.functions[index] = annotatedFunction
            }

            return resultObject
        } catch {
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration about \(protocolObject.name).")
            print(error)
            return protocolObject
        }
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
