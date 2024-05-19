//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import Dependencies
import DependenciesMacros
import SourceKittenFramework

@DependencyClient
public struct SourceKitClient {
    public var sendCursorInfoRequest: @Sendable (
        _ file: String,
        _ offset: Int,
        _ sourceFilePaths: [String],
        _ arguments: [String]
    ) async throws -> [String: SourceKitRepresentable]
}

extension SourceKitClient: DependencyKey {
    public static let liveValue: Self = .init(
        sendCursorInfoRequest: { file, offset, _, arguments in
            let byteCount = ByteCount(offset)
            let request = Request.cursorInfo(file: file, offset: byteCount, arguments: arguments)
            let response = try await request.asyncSend()

            return response
        }
    )
}
