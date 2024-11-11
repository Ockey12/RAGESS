//
//  SwiftIndexStoreClient.swift
//
//
//  Created by Ockey12 on 2024/11/11
//
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftIndexStore

@DependencyClient
public struct SwiftIndexStoreClient {
    public var extractDefinitions: (_ indexStoreURL: URL, _ projectRootPath: String) throws -> [IndexStoreSymbol]
}

extension SwiftIndexStoreClient: DependencyKey {
    public static let liveValue: SwiftIndexStoreClient = .init(
        extractDefinitions: { indexStoreURL, projectRootPath in
            let indexStore = try IndexStore.open(store: indexStoreURL, lib: .open())
            var result = [IndexStoreSymbol]()
            try indexStore.forEachUnits { unit in
                try indexStore.forEachRecordDependencies(for: unit) { dependency in
                    guard case let .record(record) = dependency,
                          let recordPath = record.filePath,
                          recordPath.starts(with: projectRootPath)
                    else {
                        return true
                    }
                    try indexStore.forEachOccurrences(for: record) { occurrence in
                        guard occurrence.roles.contains(.definition),
                              let usr = occurrence.symbol.usr,
                              let location = occurrence.location.path
                        else {
                            return true
                        }
                        result.append(.init(
                            usr: usr,
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

public struct IndexStoreSymbol {
    public let usr: String
    public let fullPath: String
    public let line: Int
    public let column: Int

    public init(usr: String, fullPath: String, line: Int64, column: Int64) {
        self.usr = usr
        self.fullPath = fullPath
        self.line = Int(line)
        self.column = Int(column)
    }
}
