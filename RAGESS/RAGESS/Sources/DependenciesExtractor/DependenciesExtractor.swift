//
//  DependenciesExtractor.swift
//
//
//  Created by Ockey12 on 2024/11/17
//
//

import DeclaredObject
import DependencyObject
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
        let references = indexStoreObjects.filter { $0.roles.contains(.reference) }

        var dependencies = [DependencyObject]()
        for reference in references {
            guard let callerUSRs = findCaller(
                indexStoreObject: reference,
                rootDirectory: rootDirectory,
                sourceFileTable: sourceFileTable
            ) else {
                continue
            }

            dependencies.append(.init(calleeUSR: reference.usr, callerUSRs: callerUSRs, roles: reference.roles))
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
            where: { $0.rangeInXcode.contains(indexStoreObject.locationInXcode) }
        ) else {
            return nil
        }

        return findUSR(location: indexStoreObject.locationInXcode, declaredObject: declaredObject)
    }

    private static func findUSR(location: LocationInXcode, declaredObject: DeclaredObject) -> [USR] {
        // Search from the kind that is most likely to meet the conditions.

        for variableObject in declaredObject.variables {
            if variableObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: variableObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for functionObject in declaredObject.functions {
            if functionObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: functionObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for initializerObject in declaredObject.initializers {
            if initializerObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: initializerObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for caseObject in declaredObject.cases {
            if caseObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: caseObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for attributeObject in declaredObject.attributes {
            if attributeObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: attributeObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for enumObject in declaredObject.nestingEnums {
            if enumObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: enumObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for structObject in declaredObject.nestingStructs {
            if structObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: structObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for classObject in declaredObject.nestingClasses {
            if classObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: classObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for actorObject in declaredObject.nestingActors {
            if actorObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: actorObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        for protocolObject in declaredObject.nestingProtocols {
            if protocolObject.rangeInXcode.contains(location) {
                let childUSRs = findUSR(location: location, declaredObject: protocolObject)
                if childUSRs.isEmpty {
                    return declaredObject.usrs
                } else {
                    return childUSRs
                }
            }
        }

        return declaredObject.usrs
    }
}
