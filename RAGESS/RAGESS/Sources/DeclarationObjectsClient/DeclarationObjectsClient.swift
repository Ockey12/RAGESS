//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/15
//  
//

import Dependencies
import DependenciesMacros
import TypeDeclaration

@DependencyClient
public struct DeclarationObjectsClient {
    public var get: @Sendable () async -> [any DeclarationObject] = { [] }
    public var set: @Sendable (
        _ objects: [any DeclarationObject]
    ) async -> Void
}

extension DeclarationObjectsClient: DependencyKey {
    public static var liveValue: Self {
        let storage = ObjectStorage()

        return .init(
            get: { await storage.objects },
            set: { newObjects in
                await storage.set(newObjects)
            }
        )
    }
}

actor ObjectStorage {
    var objects: [any DeclarationObject] = []

    func set(_ newObjects: [any DeclarationObject]) {
        objects = newObjects
    }
}
