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
        print("DEPENDENCIES")
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("TIME ELAPSED: \(timeElapsed)")
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
#endif

        return declarationObjects
    }
}

private func printDependencies(
    of object: any DeclarationObject,
    declarationObjects: [any DeclarationObject]
) {
    for dependency in object.objectsThatAreCalledByThisObject {
        printDependency(of: dependency, declarationObjects: declarationObjects)
    }
    for dependency in object.objectsThatCallThisObject {
        printDependency(of: dependency, declarationObjects: declarationObjects)
    }
    if let variableObject = object as? any VariableOwner {
        for variable in variableObject.variables {
            printDependencies(of: variable, declarationObjects: declarationObjects)
        }
    }
    if let functionObject = object as? any FunctionOwner {
        for function in functionObject.functions {
            printDependencies(of: function, declarationObjects: declarationObjects)
        }
    }
    if let typeDeclaration = object as? any TypeDeclaration {
        for nestingStruct in typeDeclaration.nestingStructs {
            printDependencies(of: nestingStruct, declarationObjects: declarationObjects)
        }
        for nestingClass in typeDeclaration.nestingClasses {
            printDependencies(of: nestingClass, declarationObjects: declarationObjects)
        }
        for nestingEnum in typeDeclaration.nestingEnums {
            printDependencies(of: nestingEnum, declarationObjects: declarationObjects)
        }
    }

    func printDependency(
        of dependencyObject: DependencyObject,
        declarationObjects: [any DeclarationObject]
    ) {
//        let callerObjectIndex = dependencyObject.
    }
}
