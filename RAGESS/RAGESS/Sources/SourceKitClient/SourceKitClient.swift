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
    public var sendCursorInfoRequest: @Sendable(
        _ file: String,
        _ offset: Int,
        _ arguments: [String]
    ) async throws -> Void
}

extension SourceKitClient: DependencyKey {
    public static let liveValue: Self = {
        return .init(
            sendCursorInfoRequest: { file, offset, arguments in
                let byteCount = ByteCount(offset)
                let request = Request.cursorInfo(file: file, offset: byteCount, arguments: arguments)
                let response = try await request.asyncSend()
                dump(response)
            }
        )
    }()
}
