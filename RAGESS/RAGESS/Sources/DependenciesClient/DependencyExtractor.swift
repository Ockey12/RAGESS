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
        declarationObjects: inout [any DeclarationObject],
        allSourceFiles: [SourceFile],
        buildSettings: [String: String],
        packages: [PackageObject]
    ) async {
        print("\(#filePath) - \(#function)")

        let allSourceFilePaths = allSourceFiles.map { $0.path }

        #if DEBUG
        print("--- allSourceFilePaths ---")
        for path in allSourceFilePaths {
            print("    \(path)")
        }
        #endif

        for sourceFile in allSourceFiles {
            let generator = CompilerArgumentsGenerator(
                targetFilePath: sourceFile.path,
                buildSettings: buildSettings,
                sourceFilePaths: allSourceFilePaths,
                packages: packages
            )

            guard let arguments = try? generator.generateArguments() else {
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
        declarationObjects: inout [any DeclarationObject],
        allSourceFilePaths: [String],
        sourceKitArguments: [String]
    ) async {
        #if DEBUG
            print("\(#filePath) - \(#function)")
            print("from \(sourceFile.path)")
        #endif

        let parsedFile = Parser.parse(source: sourceFile.content)
        let visitor = Visitor(
            locationConverter: SourceLocationConverter(
                fileName: sourceFile.path,
                tree: parsedFile
            )
        )
        visitor.walk(Syntax(parsedFile))

        for referenceOffset in visitor.referenceOffsets {
            #if DEBUG
            print("referenceOffset: \(referenceOffset)")
            #endif
            await extractDependencyObject(
                sourceFilePath: sourceFile.path,
                callerOffset: referenceOffset,
                declarationObjects: &declarationObjects,
                allSourceFilePaths: allSourceFilePaths,
                sourceKitArguments: sourceKitArguments
            )
        }

        for identifierTypeOffset in visitor.identifierTypeOffsets {
            #if DEBUG
            print("identifierTypeOffset: \(identifierTypeOffset)")
            #endif
            await extractDependencyObject(
                sourceFilePath: sourceFile.path,
                callerOffset: identifierTypeOffset,
                declarationObjects: &declarationObjects,
                allSourceFilePaths: allSourceFilePaths,
                sourceKitArguments: sourceKitArguments
            )
        }

        for inheritOffset in visitor.inheritOffsets {
            #if DEBUG
            print("inheritOffset: \(inheritOffset)")
            #endif
            await extractDependencyObject(
                sourceFilePath: sourceFile.path,
                callerOffset: inheritOffset,
                declarationObjects: &declarationObjects,
                allSourceFilePaths: allSourceFilePaths,
                sourceKitArguments: sourceKitArguments
            )
        }
    }

    private func extractDependencyObject(
        sourceFilePath: String,
        callerOffset: Int,
        declarationObjects: inout [any DeclarationObject],
        allSourceFilePaths: [String],
        sourceKitArguments: [String]
    ) async {
        do {
            @Dependency(SourceKitClient.self) var sourceKitClient

            let response = try await sourceKitClient.sendCursorInfoRequest(
                file: sourceFilePath,
                offset: callerOffset,
                sourceFilePaths: allSourceFilePaths,
                arguments: sourceKitArguments
            )

#if DEBUG
            print("sourceKitClient.sendCursorInfoRequest")
#endif

            // MARK: Definition object

            guard let definitionFilePath = response[CursorInfoResponseKeys.filePath.key] as? String else {
                print("ERROR in \(#filePath) - \(#function): Cannot find `key.filepath`.\n")
                return
            }
            #if DEBUG
            print("definitionFilePath: \(definitionFilePath)")
            #endif

            guard let definitionOffset = response[CursorInfoResponseKeys.offset.key] as? Int64 else {
                print("ERROR in \(#filePath) - \(#function): Cannot find `key.offset`.\n")
                return
            }
            #if DEBUG
            print("definitionOffset: \(definitionOffset)")
            #endif

            guard let definitionObjectIndex = declarationObjects.firstIndex(where: {
                $0.fullPath == definitionFilePath
                && $0.offsetRange.contains(Int(definitionOffset))
            }) else {
                print("ERROR in \(#filePath) - \(#function): Cannot find definition object in [DeclarationObject].\n")
                return
            }

            var optionalDefinitionKeyPath: DependencyObject.Object.ObjectKeyPath?

            if let protocolObject = declarationObjects[definitionObjectIndex] as? ProtocolObject {
                guard let keyPath = findProperty(in: protocolObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(protocolObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .protocol(keyPath)

            } else if let structObject = declarationObjects[definitionObjectIndex] as? StructObject {
                guard let keyPath = findProperty(in: structObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(structObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .struct(keyPath)

            } else if let classObject = declarationObjects[definitionObjectIndex] as? ClassObject {
                guard let keyPath = findProperty(in: classObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(classObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .class(keyPath)

            } else if let enumObject = declarationObjects[definitionObjectIndex] as? EnumObject {
                guard let keyPath = findProperty(in: enumObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(enumObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .enum(keyPath)

            } else if let variableObject = declarationObjects[definitionObjectIndex] as? VariableObject {
                guard let keyPath = findProperty(in: variableObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(variableObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .variable(keyPath)

            } else if let functionObject = declarationObjects[definitionObjectIndex] as? FunctionObject {
                guard let keyPath = findProperty(in: functionObject, matching: {
                    $0.offsetRange.contains(Int(definitionOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(functionObject.name)\n")
                    return
                }
                optionalDefinitionKeyPath = .function(keyPath)

            } else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast to any DeclarationObject.\n")
                return
            }

            // MARK: Caller object

            guard let callerObjectIndex = declarationObjects.firstIndex(where: {
                $0.fullPath == sourceFilePath
                && $0.offsetRange.contains(callerOffset)
            }) else {
                print("ERROR in \(#filePath) - \(#function): Cannot find caller object in [DeclarationObject].\n")
                return
            }

            var optionalCallerKeyPath: DependencyObject.Object.ObjectKeyPath?

            if let protocolObject = declarationObjects[callerObjectIndex] as? ProtocolObject {
                guard let keyPath = findProperty(in: protocolObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(protocolObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .protocol(keyPath)

            } else if let structObject = declarationObjects[callerObjectIndex] as? StructObject {
                guard let keyPath = findProperty(in: structObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(structObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .struct(keyPath)

            } else if let classObject = declarationObjects[callerObjectIndex] as? ClassObject {
                guard let keyPath = findProperty(in: classObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(classObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .class(keyPath)

            } else if let enumObject = declarationObjects[callerObjectIndex] as? EnumObject {
                guard let keyPath = findProperty(in: enumObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(enumObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .enum(keyPath)

            } else if let variableObject = declarationObjects[callerObjectIndex] as? VariableObject {
                guard let keyPath = findProperty(in: variableObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(variableObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .variable(keyPath)

            } else if let functionObject = declarationObjects[callerObjectIndex] as? FunctionObject {
                guard let keyPath = findProperty(in: functionObject, matching: {
                    $0.offsetRange.contains(Int(callerOffset))
                }) else {
                    print("ERROR in \(#filePath) - \(#function): Cannot find property in \(functionObject.name)\n")
                    return
                }
                optionalCallerKeyPath = .function(keyPath)

            } else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast to any DeclarationObject.\n")
                return
            }

            // MARK: Result

            let callerObject = declarationObjects[callerObjectIndex]
            let definitionObject = declarationObjects[definitionObjectIndex]
            guard let callerKeyPath = optionalCallerKeyPath else {
                print("ERROR in \(#filePath) - \(#function): Cannot unwrap optionalCallerKeyPath.\n")
                return
            }
            guard let definitionKeyPath = optionalDefinitionKeyPath else {
                print("ERROR in \(#filePath) - \(#function): Cannot unwrap optionalDefinitionKeyPath.\n")
                return
            }

            let dependencyObject = DependencyObject(
                callerObject: .init(
                    id: callerObject.id,
                    keyPath: callerKeyPath
                ),
                definitionObject: .init(
                    id: definitionObject.id,
                    keyPath: definitionKeyPath
                )
            )

            declarationObjects[callerObjectIndex].objectsThatAreCalledByThisObject.append(dependencyObject)
            declarationObjects[definitionObjectIndex].objectsThatCallThisObject.append(dependencyObject)

        } catch {
            print("ERROR in \(#filePath) - \(#function): \(error)")
            return
        }
    }

//    private func extractInheritDependencies(
//        by inheritableObject: any Inheritable,
//        declarationObjects: [any DeclarationObject],
//        allSourceFilePaths: [String],
//        buildSettings: [String: String],
//        packages: [PackageObject]
//    ) async {
//        @Dependency(SourceKitClient.self) var sourceKitClient
//
//#if DEBUG
//        print("\(#filePath) - \(#function)")
//        print("by \(inheritableObject.name)")
//#endif
//
//        let argumentsGenerator = CompilerArgumentsGenerator(
//            targetFilePath: inheritableObject.fullPath,
//            buildSettings: buildSettings,
//            sourceFilePaths: allSourceFilePaths,
//            packages: packages
//        )
//
//        for inheritOffset in inheritableObject.inheritOffsets {
//            print("inheritOffset: \(inheritOffset)")
//
//            do {
//                let arguments = try argumentsGenerator.generateArguments()
//
//                let response = try await sourceKitClient.sendCursorInfoRequest(
//                    file: inheritableObject.fullPath,
//                    offset: inheritOffset,
//                    sourceFilePaths: allSourceFilePaths,
//                    arguments: arguments
//                )
//
//                guard let inheritedObjectPath = response[CursorInfoResponseKeys.filePath.key] as? String else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.filepath`.\n")
//                    continue
//                }
//                print("inheritedObjectPath: \(inheritedObjectPath)")
//
//                guard let inheritedObjectOffset = response[CursorInfoResponseKeys.offset.key] as? Int64 else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find `key.offset`.\n")
//                    continue
//                }
//                print("inheritedObjectOffset: \(inheritedObjectOffset)")
//
//                guard let inheritedObjectIndex = declarationObjects.firstIndex(where: {
//                    $0.fullPath == inheritedObjectPath
//                    && $0.offsetRange.contains(Int(inheritedObjectOffset))
//                }) else {
//                    print("ERROR in \(#filePath) - \(#function): Cannot find inherited object in [DeclarationObject].\n")
//                    continue
//                }
//
//                var optionalInheritedObjectKeyPath: DependencyObject.Object.ObjectKeyPath?
//                // Only protocols or classes are inherited, but they may be nested by structs, variables, etc.
//                if let protocolObject = declarationObjects[inheritedObjectIndex] as? ProtocolObject {
//                    guard let keyPath = findProperty(in: protocolObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(protocolObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .protocol(keyPath)
//
//                } else if let structObject = declarationObjects[inheritedObjectIndex] as? StructObject {
//                    guard let keyPath = findProperty(in: structObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(structObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .struct(keyPath)
//
//                } else if let classObject = declarationObjects[inheritedObjectIndex] as? ClassObject {
//                    guard let keyPath = findProperty(in: classObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(classObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .class(keyPath)
//
//                } else if let enumObject = declarationObjects[inheritedObjectIndex] as? EnumObject {
//                    guard let keyPath = findProperty(in: enumObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(enumObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .enum(keyPath)
//
//                } else if let variableObject = declarationObjects[inheritedObjectIndex] as? VariableObject {
//                    guard let keyPath = findProperty(in: variableObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(variableObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .variable(keyPath)
//
//                } else if let functionObject = declarationObjects[inheritedObjectIndex] as? FunctionObject {
//                    guard let keyPath = findProperty(in: functionObject, matching: {
//                        $0.offsetRange.contains(Int(inheritOffset))
//                    }) else {
//                        print("ERROR in \(#filePath) - \(#function): Cannot find property in \(functionObject.name)\n")
//                        continue
//                    }
//                    optionalInheritedObjectKeyPath = .function(keyPath)
//
//                } else {
//                    print("ERROR in \(#filePath) - \(#function): The inherited type is neither protocol nor class.\n")
//                    continue
//                }
//            } catch {
//
//            }
//        }
//    }

    private func findProperty<T: TypeDeclaration>(in typeObject: T, matching: (any DeclarationObject) -> Bool) -> PartialKeyPath<T>? {
        guard matching(typeObject) else {
            print("ERROR in \(#filePath) - \(#function): \(typeObject.name) does not match `matching(typeObject)`\n")
            return nil
        }

        for (index, nestProtocol) in typeObject.nestingProtocols.enumerated() {
            if matching(nestProtocol) {
                let keyPath: PartialKeyPath<T> = \T.nestingProtocols[index]
                if let childKeyPath = findProperty(in: nestProtocol, matching: matching) {
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

        let keyPath: PartialKeyPath<T> = \T.self
        return keyPath
    }

    private func findProperty<T: DeclarationObject>(in object: T, matching: (any DeclarationObject) -> Bool) -> PartialKeyPath<T>? {
        guard matching(object) else {
            print("ERROR in \(#filePath) - \(#function): \(object.name) does not match `matching(object)`\n")
            return nil
        }

        for (index, nestProtocol) in object.nestingProtocols.enumerated() {
            if matching(nestProtocol) {
                let keyPath: PartialKeyPath<T> = \T.nestingProtocols[index]
                if let childKeyPath = findProperty(in: nestProtocol, matching: matching) {
                    return keyPath.appending(path: childKeyPath)
                }
                return keyPath
            }
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
