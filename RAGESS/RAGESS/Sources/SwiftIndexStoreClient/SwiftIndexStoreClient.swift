//
//  SwiftIndexStoreClient.swift
//
//
//  Created by Ockey12 on 2024/11/11
//
//

import DeclaredObject
import Dependencies
import DependenciesMacros
import Foundation
import SwiftIndexStore
import SwiftIndexStoreObject

@DependencyClient
public struct SwiftIndexStoreClient {
    public var extractOccurrences: (_ indexStoreURL: URL, _ projectRootPath: String) throws -> [IndexStoreObject]
}

extension SwiftIndexStoreClient: DependencyKey {
    public static let liveValue: SwiftIndexStoreClient = .init(
        extractOccurrences: { indexStoreURL, projectRootPath in
            let indexStore = try IndexStore.open(store: indexStoreURL, lib: .open())
            var result = [IndexStoreObject]()
            try indexStore.forEachUnits { unit in
                try indexStore.forEachRecordDependencies(for: unit) { dependency in
                    guard case let .record(record) = dependency,
                          let recordPath = record.filePath,
                          recordPath.starts(with: projectRootPath)
                    else {
                        return true
                    }
                    try indexStore.forEachOccurrences(for: record) { occurrence in
                        guard occurrence.roles.contains(.definition) || occurrence.roles.contains(.reference),
                              let usr = occurrence.symbol.usr,
                              let location = occurrence.location.path
                        else {
                            return true
                        }

                        var roles: [IndexStoreObject.Role] = []
                        if occurrence.roles.contains(.definition) {
                            roles.append(.definition)
                        } else if occurrence.roles.contains(.reference) {
                            roles.append(.reference)
                            if occurrence.roles.contains(.baseOf) {
                                roles.append(.baseOf)
                            }
                        }

                        result.append(.init(
                            usr: usr,
                            roles: roles,
                            fullPath: location,
                            line: occurrence.location.line,
                            column: occurrence.location.column
                        ))
                        return true
                    }
                    return true
                }
                return true
            }
            return result
        }
    )
}

extension SwiftIndexStoreClient: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self()
}

public extension DependencyValues {
    var swiftIndexStoreClient: SwiftIndexStoreClient {
        get { self[SwiftIndexStoreClient.self] }
        set { self[SwiftIndexStoreClient.self] = newValue }
    }
}
