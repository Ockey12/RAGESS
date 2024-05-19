//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import Dependencies
import SourceKitClient
import SwiftParser
import SwiftSyntax
import TypeDeclaration
import XcodeObject

public struct DeclarationExtractor {
    public init() {}

    public func extractDeclarations(
        from sourceFile: SourceFile,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> [any DeclarationObject] {
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

        var result: [any DeclarationObject] = visitor.extractedDeclarations

        for (index, object) in result.enumerated() {
            let annotatedObject = await getAnnotatedDeclaration(
                object,
                buildSettings: buildSettings,
                sourceFilePaths: sourceFilePaths,
                packages: packages
            )
            result[index] = annotatedObject
        }

        return result
    }

    // Used for `StructObject`, `ClassObject`, `EnumObject`.
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
            resultObject.annotatedDecl = annotatedDecl

            for (index, initializer) in typeObject.initializerObjects.enumerated() {
                let annotatedInit = await getAnnotatedDeclaration(
                    initializer,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.initializerObjects[index] = annotatedInit
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

    // Used for `VariableObject`, `FunctionObject`.
    private func getAnnotatedDeclaration<T: TypeNestable>(
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
            resultObject.annotatedDecl = annotatedDecl

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

            for (index, initializer) in protocolObject.initializerObjects.enumerated() {
                let annotatedInit = await getAnnotatedDeclaration(
                    initializer,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.initializerObjects[index] = annotatedInit
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

    // Used for `InitializerObject`.
    private func getAnnotatedDeclaration<T: DeclarationObject>(
        _ inputObject: T,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) async -> T {
        @Dependency(SourceKitClient.self) var sourceKitClient
        let argumentsGenerator = CompilerArgumentsGenerator(
            targetFilePath: inputObject.fullPath,
            buildSettings: buildSettings,
            sourceFilePaths: sourceFilePaths,
            packages: packages
        )

        do {
            let arguments = try argumentsGenerator.generateArguments()
            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: inputObject.fullPath,
                offset: inputObject.nameOffset,
                sourceFilePaths: sourceFilePaths,
                arguments: arguments
            )

            guard let annotatedDecl = response[CursorInfoResponseKeys.fullyAnnotatedDecl.key] as? String else {
                print("ERROR: \(#file) - \(#function): Cannot find `key.fully_annotated_decl` about \(inputObject.name).")
                return inputObject
            }

            var resultObject = inputObject
            resultObject.annotatedDecl = annotatedDecl

            for (index, variable) in inputObject.variables.enumerated() {
                let annotatedVariable = await getAnnotatedDeclaration(
                    variable,
                    buildSettings: buildSettings,
                    sourceFilePaths: sourceFilePaths,
                    packages: packages
                )
                resultObject.variables[index] = annotatedVariable
            }

            for (index, function) in inputObject.functions.enumerated() {
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
            print("ERROR: \(#file) - \(#function): Cannot get annotated declaration about \(inputObject.name).")
            print(error)
            return inputObject
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
