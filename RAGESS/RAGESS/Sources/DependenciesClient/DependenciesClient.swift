//
//  DependenciesClient.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import Dependencies
import DependenciesMacros
import TypeDeclaration

@DependencyClient
public struct DependenciesClient {
    public var extractDependencies: @Sendable (
        _ projectRootPath: String,
        _ declarationObjects: [any DeclarationObject]
    ) async throws -> [any DeclarationObject]
}

extension DependenciesClient: DependencyKey {
    public static let liveValue: DependenciesClient = .init { projectRootPath, objects in
        var declarationObjects = objects
        return declarationObjects
    }
}
