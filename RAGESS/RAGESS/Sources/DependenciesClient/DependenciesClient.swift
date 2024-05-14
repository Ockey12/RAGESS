//
//  DependenciesClient.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import Dependencies
import DependenciesMacros
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
        print("\(#filePath) - \(#function)")
        var declarationObjects = objects
        let extractor = DependencyExtractor()
        await extractor.extract(
            declarationObjects: &declarationObjects,
            allSourceFiles: allSourceFiles,
            buildSettings: buildSettings,
            packages: packages
        )
        return declarationObjects
    }
}
