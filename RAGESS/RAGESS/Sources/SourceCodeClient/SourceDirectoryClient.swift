//
//  SourceDirectoryClient.swift
//
//
//  Created by ockey12 on 2024/04/12.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct SourceDirectoryClient {
    public var getSourceCode: @Sendable (_ rootDirectoryPath: String) async throws -> Void
}

extension SourceDirectoryClient: DependencyKey {
    public static let liveValue: Self = .init(
        getSourceCode: { rootDirectoryPath in
            let fileURLs = try FileManager.default.subpathsOfDirectory(atPath: rootDirectoryPath)
            dump(fileURLs)
        }
    )
}
