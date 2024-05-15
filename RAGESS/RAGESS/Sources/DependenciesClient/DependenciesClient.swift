//
//  DependenciesClient.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import Dependencies
import DependenciesMacros
import Foundation
import TypeDeclaration
import XcodeObject

@DependencyClient
public struct DependenciesClient {
    public var extractDependencies: @Sendable (
        _ declarationObjects: [any DeclarationObject],
        _ allSourceFiles: [SourceFile],
        _ buildSettings: [String: String],
        _ packages: [PackageObject]
    ) async throws -> [any DeclarationObject]
}

extension DependenciesClient: DependencyKey {
    public static let liveValue: DependenciesClient = .init {
        objects, allSourceFiles, buildSettings, packages in
#if DEBUG
        print("\(#filePath) - \(#function)")
        let startTime = CFAbsoluteTimeGetCurrent()
#endif

        var declarationObjects = objects
        let extractor = DependencyExtractor()
        await extractor.extract(
            declarationObjects: &declarationObjects,
            allSourceFiles: allSourceFiles,
            buildSettings: buildSettings,
            packages: packages
        )

#if DEBUG
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        var numberOfDependencyObjects = 0
        for object in declarationObjects {
            printDependencies(of: object, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
        print("NUMBER OF DEPENDENCIES: \(numberOfDependencyObjects)")
        print("TIME ELAPSED: \(timeElapsed)")
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
#endif

        return declarationObjects
    }
}

#if DEBUG
private func printDependencies(
    of object: any DeclarationObject,
    declarationObjects: [any DeclarationObject],
    numberOfDependencyObjects: inout Int
) {
    for dependency in object.objectsThatAreCalledByThisObject {
        printDependency(of: dependency, declarationObjects: declarationObjects)
    }
    numberOfDependencyObjects += object.objectsThatAreCalledByThisObject.count

    for dependency in object.objectsThatCallThisObject {
        printDependency(of: dependency, declarationObjects: declarationObjects)
    }
    numberOfDependencyObjects += object.objectsThatCallThisObject.count

    if let variableObject = object as? any VariableOwner {
        for variable in variableObject.variables {
            printDependencies(of: variable, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
    }
    if let functionObject = object as? any FunctionOwner {
        for function in functionObject.functions {
            printDependencies(of: function, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
    }
    if let typeDeclaration = object as? any TypeDeclaration {
        for nestingStruct in typeDeclaration.nestingStructs {
            printDependencies(of: nestingStruct, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
        for nestingClass in typeDeclaration.nestingClasses {
            printDependencies(of: nestingClass, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
        for nestingEnum in typeDeclaration.nestingEnums {
            printDependencies(of: nestingEnum, declarationObjects: declarationObjects, numberOfDependencyObjects: &numberOfDependencyObjects)
        }
    }

    func printDependency(
        of dependencyObject: DependencyObject,
        declarationObjects: [any DeclarationObject]
    ) {
        guard let callerObject = declarationObjects.first(where: { $0.id == dependencyObject.callerObject.id }) else {
            print("ERROR in \(#filePath) - \(#function): Cannot find `callerObject` in `declarationObjects`.\n")
            return
        }
        guard let definitionObject = declarationObjects.first(where: { $0.id == dependencyObject.definitionObject.id }) else {
            print("ERROR in \(#filePath) - \(#function): Cannot find `definitionObject` in `declarationObjects`.\n")
            return
        }

        var debugText = ""

        switch dependencyObject.callerObject.keyPath {
        case let .struct(partialKeyPath):
            guard let structObject = callerObject as? StructObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` to `StructObject`.\n")
                return
            }
            guard let component = structObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `structObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .class(partialKeyPath):
            guard let classObject = callerObject as? ClassObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` to `ClassObject`.\n")
                return
            }
            guard let component = classObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `classObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .enum(partialKeyPath):
            guard let enumObject = callerObject as? EnumObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `EnumObject`.\n")
                return
            }
            guard let component = enumObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `enumObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .variable(partialKeyPath):
            guard let variableObject = callerObject as? VariableObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `VariableObject`.\n")
                return
            }
            guard let component = variableObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `variableObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .function(partialKeyPath):
            guard let functionObject = callerObject as? FunctionObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `FunctionObject`.\n")
                return
            }
            guard let component = functionObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `functionObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        }

        debugText += "  ↓ calls\n"

        switch dependencyObject.definitionObject.keyPath {
        case let .struct(partialKeyPath):
            guard let structObject = definitionObject as? StructObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` to `StructObject`.\n")
                return
            }
            guard let component = structObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `structObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .class(partialKeyPath):
            guard let classObject = definitionObject as? ClassObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` to `ClassObject`.\n")
                return
            }
            guard let component = classObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `classObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .enum(partialKeyPath):
            guard let enumObject = definitionObject as? EnumObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `EnumObject`.\n")
                return
            }
            guard let component = enumObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `enumObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .variable(partialKeyPath):
            guard let variableObject = definitionObject as? VariableObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `VariableObject`.\n")
                return
            }
            guard let component = variableObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `variableObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        case let .function(partialKeyPath):
            guard let functionObject = definitionObject as? FunctionObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `callerObject` `FunctionObject`.\n")
                return
            }
            guard let component = functionObject[keyPath: partialKeyPath] as? any DeclarationObject else {
                print("ERROR in \(#filePath) - \(#function): Cannot cast `functionObject[keyPath: partialKeyPath]` to `any DeclarationObject`.\n")
                return
            }
            debugText += "\(component.fullPath)\n╰─\(component.name)\n"
        }

        debugText += "\n"

        print(debugText)
    }
}
#endif
