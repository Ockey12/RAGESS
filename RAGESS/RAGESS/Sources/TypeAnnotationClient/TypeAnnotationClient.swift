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
import XcodeObject

@DependencyClient
public struct TypeAnnotationClient {
    public var setTypeAnnotations: @Sendable (_ sourceFile: SourceFile) async throws -> String
}

extension TypeAnnotationClient: DependencyKey {
    public static let liveValue: Self = {
        @Dependency(LSPClient.self) var lspClient

        return .init(
            setTypeAnnotations: { sourceFile in
                let lastPosition = sourceFile.content.lastPosition
                let range = Position(line: 0, utf16index: 0) ..< lastPosition
                let inlayHints = try await lspClient.sendInlayHintRequest(sourceFile: sourceFile, range: range)
                let typeAnnotations = inlayHints.filter { $0.kind == .type }
                    .sorted { $0.position.utf16index > $1.position.utf16index }
                #if DEBUG
                    print("\nType Annotations")
                    dump(typeAnnotations)
                #endif
                var annotatedCode = sourceFile.content
                for typeAnnotation in typeAnnotations {
                    guard case let .string(additionalString) = typeAnnotation.label else {
                        continue
                    }
                    annotatedCode.insert(additionalString, into: typeAnnotation.position)
                }
                return annotatedCode
            }
        )
    }()
}
