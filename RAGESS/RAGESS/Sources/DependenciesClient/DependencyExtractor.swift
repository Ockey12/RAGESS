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

                guard let definitionFilePath = response[CursorInfoResponseKeys.filePath.key] as? String else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.filepath`.\n")
                    continue
                }
                print("definitionFilePath: \(definitionFilePath)")

                guard let definitionLine = response[CursorInfoResponseKeys.line.key] as? Int64 else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.line`.\n")
                    continue
                }
                print("definitionLine: \(definitionLine)")

                guard let definitionColumn = response[CursorInfoResponseKeys.column.key] as? Int64 else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.column`.\n")
                    continue
                }
                print("definitionColumn: \(definitionColumn)")

                guard let definitionOffset = response[CursorInfoResponseKeys.offset.key] as? Int64 else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.offset`.\n")
                    continue
                }
                print("definitionOffset: \(definitionOffset)")

//                let definitionPosition = SourcePosition(line: definitionLine, utf8index: definitionColumn)
                guard let definitionObjectIndex = declarationObjects.firstIndex(where: {
                    $0.fullPath == definitionFilePath
                        && $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find definition object in [\(DeclarationObject.self)].\n")
                    continue
                }

                var definitionVariableKeyPath: PartialKeyPath<VariableObject>?
                var definitionFunctionKeyPath: PartialKeyPath<FunctionObject>?
                var definitionStructKeyPath: PartialKeyPath<StructObject>?
                var definitionClassKeyPath: PartialKeyPath<ClassObject>?
                var definitionEnumKeyPath: PartialKeyPath<EnumObject>?
                if let variableObject = declarationObjects[definitionObjectIndex] as? VariableObject {
                    guard let keyPath = findProperty(in: variableObject, matching: {
                        $0.offsetRange.contains(Int(definitionOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(variableObject.name)\n")
                        continue
                    }
                    definitionVariableKeyPath = keyPath
                    print("definition: \(variableObject[keyPath: keyPath])")
                } else if let functionObject = declarationObjects[definitionObjectIndex] as? FunctionObject {
                    guard let keyPath = findProperty(in: functionObject, matching: {
                        $0.offsetRange.contains(Int(definitionOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(functionObject.name)\n")
                        continue
                    }
                    definitionFunctionKeyPath = keyPath
                    print("definition: \(functionObject[keyPath: keyPath])")
                } else if let structObject = declarationObjects[definitionObjectIndex] as? StructObject {
                    guard let keyPath = findProperty(in: structObject, matching: {
                        $0.offsetRange.contains(Int(definitionOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(structObject.name)\n")
                        continue
                    }
                    definitionStructKeyPath = keyPath
                    print("definition: \(structObject[keyPath: keyPath])")
                } else if let classObject = declarationObjects[definitionObjectIndex] as? ClassObject {
                    guard let keyPath = findProperty(in: classObject, matching: {
                        $0.offsetRange.contains(Int(definitionOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(classObject.name)\n")
                        continue
                    }
                    definitionClassKeyPath = keyPath
                    print("definition: \(classObject[keyPath: keyPath])")
                } else if let enumObject = declarationObjects[definitionObjectIndex] as? EnumObject {
                    guard let keyPath = findProperty(in: enumObject, matching: {
                        $0.offsetRange.contains(Int(definitionOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(enumObject.name)\n")
                        continue
                    }
                    definitionEnumKeyPath = keyPath
                    print("definition: \(enumObject[keyPath: keyPath])")
                } else {
                    print("ERROR in \(#filePath) - \(#function): Cannot cast to any DeclarationObject.\n")
                    continue
                }

                guard let callerObjectIndex = declarationObjects.firstIndex(where: {
                    $0.fullPath == sourceFile.path
                        && $0.offsetRange.contains(callerOffset)
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [\(DeclarationObject.self)].\n")
                    continue
                }

                var callerVariableKeyPath: PartialKeyPath<VariableObject>?
                var callerFunctionKeyPath: PartialKeyPath<FunctionObject>?
                var callerStructKeyPath: PartialKeyPath<StructObject>?
                var callerClassKeyPath: PartialKeyPath<ClassObject>?
                var callerEnumKeyPath: PartialKeyPath<EnumObject>?
                if let variableObject = declarationObjects[callerObjectIndex] as? VariableObject {
                    guard let keyPath = findProperty(in: variableObject, matching: {
                        $0.offsetRange.contains(Int(callerOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(variableObject.name)\n")
                        continue
                    }
                    callerVariableKeyPath = keyPath
                    print("caller: \(variableObject[keyPath: keyPath])")
                } else if let functionObject = declarationObjects[callerObjectIndex] as? FunctionObject {
                    guard let keyPath = findProperty(in: functionObject, matching: {
                        $0.offsetRange.contains(Int(callerOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(functionObject.name)\n")
                        continue
                    }
                    callerFunctionKeyPath = keyPath
                    print("caller: \(functionObject[keyPath: keyPath])")
                } else if let structObject = declarationObjects[callerObjectIndex] as? StructObject {
                    guard let keyPath = findProperty(in: structObject, matching: {
                        $0.offsetRange.contains(Int(callerOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(structObject.name)\n")
                        continue
                    }
                    callerStructKeyPath = keyPath
                    print("caller: \(structObject[keyPath: keyPath])")
                } else if let classObject = declarationObjects[callerObjectIndex] as? ClassObject {
                    guard let keyPath = findProperty(in: classObject, matching: {
                        $0.offsetRange.contains(Int(callerOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(classObject.name)\n")
                        continue
                    }
                    callerClassKeyPath = keyPath
                    print("caller: \(classObject[keyPath: keyPath])")
                } else if let enumObject = declarationObjects[callerObjectIndex] as? EnumObject {
                    guard let keyPath = findProperty(in: enumObject, matching: {
                        $0.offsetRange.contains(Int(callerOffset))
                    }) else {
                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(enumObject.name)\n")
                        continue
                    }
                    callerEnumKeyPath = keyPath
                    print("caller: \(enumObject[keyPath: keyPath])")
                } else {
                    print("ERROR in \(#filePath) - \(#function): Cannot cast to any DeclarationObject.\n")
                    continue
                }

                print()
            } catch {
                print("ERROR in \(#filePath) - \(#function): \(error)")
            }
        }
    }

    private func extractCallerOffsets(from sourceFile: SourceFile) -> [Int] {
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

    private func findProperty<T: TypeDeclaration>(in typeObject: T, matching: (DeclarationObject) -> Bool) -> PartialKeyPath<T>? {
        guard matching(typeObject) else {
            return nil
        }

        for (index, variable) in typeObject.variables.enumerated() {
            if matching(variable) {
                let keyPath: PartialKeyPath<T> = \T.variables[index]
                if let childKeyPath = findProperty(in: variable, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }
        for (index, function) in typeObject.functions.enumerated() {
            if matching(function) {
                let keyPath: PartialKeyPath<T> = \T.functions[index]
                if let childKeyPath = findProperty(in: function, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }
        for (index, nestStruct) in typeObject.nestingStructs.enumerated() {
            if matching(nestStruct) {
                let keyPath: PartialKeyPath<T> = \T.nestingStructs[index]
                if let childKeyPath = findProperty(in: nestStruct, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }
        for (index, nestClass) in typeObject.nestingClasses.enumerated() {
            if matching(nestClass) {
                let keyPath: PartialKeyPath<T> = \T.nestingClasses[index]
                if let childKeyPath = findProperty(in: nestClass, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }
        for (index, nestEnum) in typeObject.nestingEnums.enumerated() {
            if matching(nestEnum) {
                let keyPath: PartialKeyPath<T> = \T.nestingEnums[index]
                if let childKeyPath = findProperty(in: nestEnum, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }

        let keyPath: PartialKeyPath<T> = \T.self
        return keyPath
    }

    private func findProperty<T>(in object: T, matching: (DeclarationObject) -> Bool) -> PartialKeyPath<T>? where T: VariableOwner, T: FunctionOwner {
        guard matching(object) else {
            return nil
        }

        for (index, variable) in object.variables.enumerated() {
            if matching(variable) {
                let keyPath: PartialKeyPath<T> = \T.variables[index]
                if let childKeyPath = findProperty(in: variable, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }
        for (index, function) in object.functions.enumerated() {
            if matching(function) {
                let keyPath: PartialKeyPath<T> = \T.functions[index]
                if let childKeyPath = findProperty(in: function, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
        }

        let keyPath: PartialKeyPath<T> = \T.self
        return keyPath
    }
}
