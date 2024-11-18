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
    public static func extract(indexStoreObjects: [IndexStoreObject], usrTable: USRTable, rootDirectory: Directory) -> [DependencyObject] {
        let references = indexStoreObjects.filter { $0.role == .reference }

        var dependencyTable = [DependencyObject]()
        for reference in references {
            guard let callerUSRs = findCaller(indexStoreObject: reference, rootDirectory: rootDirectory) else {
                continue
            }

            for callerUSR in callerUSRs {
                dependencyTable.append(.init(calleeUSR: reference.usr, callerUSR: callerUSR))
            }
        }

        return dependencyTable
    }

    private static func findCaller(indexStoreObject: IndexStoreObject, rootDirectory: Directory) -> [USR]? {
        guard let sourceFile = findSourceFile(in: rootDirectory, filePath: indexStoreObject.fullPath) else {
            return nil
        }

        for object in sourceFile.declaredObjects {
            if let caller = findObject(object: object, targetLocation: indexStoreObject.locationInXcode) {
                return caller.usrs
            }
        }

        return nil
    }

    private static func findSourceFile(in directory: Directory, filePath: String) -> SourceFile? {
        guard let name = findName(rootPath: directory.fullPath, filePath: filePath) else {
            return nil
        }

        switch name {
        case let .directory(name):
            guard let subDirectory = directory.subDirectories.first(where: { $0.name == name }) else {
                return nil
            }
            return findSourceFile(in: subDirectory, filePath: filePath)

        case let .sourceFile(name):
            return directory.files.first(where: { $0.name == name })
        }
    }

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
