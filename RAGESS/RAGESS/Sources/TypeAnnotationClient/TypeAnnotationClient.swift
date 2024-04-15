//
//  TypeAnnotationClient.swift
//
//
//  Created by ockey12 on 2024/04/16.
//

import Dependencies
import DependenciesMacros
import LanguageServerProtocol
import LSPClient
import SourceFileClient

@DependencyClient
public struct TypeAnnotationClient {
    public var setTypeAnnotation: @Sendable (_ sourceFile: SourceFile) async throws -> String
}

extension TypeAnnotationClient: DependencyKey {
    public static let liveValue: Self = {
        @Dependency(LSPClient.self) var lspClient

        return .init(
            setTypeAnnotation: { sourceFile in
                let lastPosition = sourceFile.content.lastPosition
                let range = Position(line: 0, utf16index: 0) ..< lastPosition
                let inlayHints = try await lspClient.sendInlayHintRequest(sourceFile: sourceFile, range: range)
                return ""
            }
        )
    }()
}
