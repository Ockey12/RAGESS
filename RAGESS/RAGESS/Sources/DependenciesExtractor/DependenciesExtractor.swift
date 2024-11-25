//
//  DependenciesExtractor.swift
//
//
//  Created by Ockey12 on 2024/11/17
//
//

import DeclaredObject
import Foundation
import SwiftIndexStoreObject
import XcodeObject

public enum DependenciesExtractor {
    public static func extract(
        indexStoreObjects: [IndexStoreObject],
        usrTable: USRTable,
        sourceFileTable: [String: WritableKeyPath<Directory, SourceFile>],
        rootDirectory: Directory
    ) -> [DependencyObject] {
        let references = indexStoreObjects.filter { $0.role == .reference }

        var dependencies = [DependencyObject]()
        for reference in references {
            guard let callerUSRs = findCaller(
                indexStoreObject: reference,
                rootDirectory: rootDirectory,
                sourceFileTable: sourceFileTable
            ) else {
                continue
            }

//            for callerUSR in callerUSRs {
//                dependencies.append(.init(calleeUSR: reference.usr, callerUSR: callerUSR))
//            }
            dependencies.append(.init(calleeUSR: reference.usr, callerUSRs: callerUSRs))
        }

        return dependencies
    }

    private static func findCaller(
        indexStoreObject: IndexStoreObject,
        rootDirectory: Directory,
        sourceFileTable: [String: WritableKeyPath<Directory, SourceFile>]
    ) -> [USR]? {
        guard let sourceFileKeyPath = sourceFileTable[indexStoreObject.fullPath] else {
            return nil
        }

        let sourceFile = rootDirectory[keyPath: sourceFileKeyPath]

        guard let declaredObject = sourceFile.declaredObjects.first(
            where: { $0.rangeInXcode.contains(indexStoreObject.locationInXcode)}
        ) else {
            return nil
        }

        return findUSR(location: indexStoreObject.locationInXcode, declaredObject: declaredObject)
    }

    private static func findUSR(location: LocationInXcode, declaredObject: DeclaredObject) -> [USR] {
        // Search from the kind that is most likely to meet the conditions.

        for variableObject in declaredObject.variables {
            if variableObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: variableObject)
            }
        }

        for functionObject in declaredObject.functions {
            if functionObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: functionObject)
            }
        }

        for initializerObject in declaredObject.initializers {
            if initializerObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: initializerObject)
            }
        }

        for caseObject in declaredObject.cases {
            if caseObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: caseObject)
            }
        }

        for enumObject in declaredObject.nestingEnums {
            if enumObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: enumObject)
            }
        }

        for structObject in declaredObject.nestingStructs {
            if structObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: structObject)
            }
        }

        for classObject in declaredObject.nestingClasses {
            if classObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: classObject)
            }
        }

        for actorObject in declaredObject.nestingActors {
            if actorObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: actorObject)
            }
        }

        for protocolObject in declaredObject.nestingProtocols {
            if protocolObject.rangeInXcode.contains(location) {
                return findUSR(location: location, declaredObject: protocolObject)
            }
        }

        return declaredObject.usrs
    }

//    private static func findSourceFile(
//        in rootDirectory: Directory,
//        filePath: String,
//        sourceFileTable: [String: WritableKeyPath<Directory, SourceFileTable>]
//    ) -> SourceFile? {
//        guard let sourceFile = sourceFileTable[filePath] else {
//            return nil
//        }
//
//        return rootDirectory[keyPath: sourceFile.keyPathFromRootDirectory]
//        guard let name = findName(rootPath: directory.fullPath, filePath: filePath) else {
//            return nil
//        }
//
//        switch name {
//        case let .directory(name):
//            guard let subDirectory = directory.subDirectories.first(where: { $0.name == name }) else {
//                return nil
//            }
//            return findSourceFile(in: subDirectory, filePath: filePath)
//
//        case let .sourceFile(name):
//            return directory.files.first(where: { $0.name == name })
//        }
//    }

    private static func findName(rootPath: String, filePath: String) -> Name? {
        guard let rootURL = URL(string: rootPath.replacingOccurrences(of: " ", with: "%20")),
              let fileURL = URL(string: filePath.replacingOccurrences(of: " ", with: "%20")) else {
            return nil
        }

        let rootURLComponents = rootURL.pathComponents
        let fileURLComponents = fileURL.pathComponents

        guard let lastIndex = fileURLComponents.firstIndex(where: { rootURLComponents.last == $0 }) else {
            return nil
        }

        let directoryNameIndex = lastIndex + 1
        guard fileURLComponents.count > directoryNameIndex else {
            return nil
        }

        let name = fileURLComponents[directoryNameIndex]
        if directoryNameIndex == fileURLComponents.endIndex - 1 {
            return .sourceFile(name)
        } else {
            return .directory(name)
        }
    }

    private enum Name {
        case directory(String)
        case sourceFile(String)
    }

    private static func findObject(object: DeclaredObject, targetLocation: LocationInXcode) -> DeclaredObject? {
        var childObjects: [DeclaredObject] = object.initializers
            + object.variables
            + object.functions
            + object.cases
            + object.nestingStructs
            + object.nestingClasses
            + object.nestingProtocols
            + object.nestingActors

        childObjects.sort(by: { $0.rangeInXcode.lowerBound < $1.rangeInXcode.lowerBound })
        if let caller = childObjects.first(where: { $0.rangeInXcode.contains(targetLocation) }) {
            return findObject(object: caller, targetLocation: targetLocation)
        }

        guard object.rangeInXcode.contains(targetLocation) else {
            return nil
        }
        return object
    }
}
