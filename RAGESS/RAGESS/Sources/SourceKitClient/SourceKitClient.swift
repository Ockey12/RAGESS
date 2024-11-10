//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import Dependencies
import DependenciesMacros
import Foundation
import SourceKittenFramework
import XcodeObject

@DependencyClient
public struct SourceKitClient {
    public var sendCursorInfoRequest: @Sendable (
        _ file: String,
        _ offset: Int,
        _ sourceFilePaths: [String],
        _ arguments: [String]
    ) async throws -> [String: SourceKitRepresentable]

    public var sendParallelCursorInfoRequest: @Sendable (
        _ requestObjects: [SourceKitRequestObject],
        _ allSourceFiles: [SourceFile]
    ) async -> [SourceKitResponse] = { _, _ in [] }
}

extension SourceKitClient: DependencyKey {
    public static let liveValue: Self = .init(
        sendCursorInfoRequest: { file, offset, _, arguments in
            let byteCount = ByteCount(offset)
            let request = Request.cursorInfo(file: file, offset: byteCount, arguments: arguments)
            let response = try await request.asyncSend()

            return response
        },
        sendParallelCursorInfoRequest: { objects, _ in
            var results = [SourceKitResponse]()

            let failures = FailureNames()

            let start = CFAbsoluteTimeGetCurrent()
            var absoluteTimes = [start]
            var times = [CFAbsoluteTime]()

            await withTaskGroup(of: SourceKitResponse?.self) { group in
                for object in objects {
                    guard let arguments = try? object.argumentsGenerator.generateArguments() else {
                        print("ERROR: \(#file) - \(#function): Could not generate SourceKit arguments of \(object.object.name)")
                        continue
                    }
                    let request = Request.cursorInfo(file: object.object.fullPath, offset: ByteCount(object.object.nameOffset), arguments: arguments)
                    group.addTask {
                        guard let response = try? await request.asyncSend() else {
                            await failures.append(object.object.name)
                            return nil
                        }
                        return SourceKitResponse(request: object, response: response)
                    }
                }

                for await response in group {
                    guard let response else {
                        continue
                    }
                    results.append(response)
                    let lastAbsoluteTime = absoluteTimes.last!
                    let current = CFAbsoluteTimeGetCurrent()
                    absoluteTimes.append(current)
                    let time = current - lastAbsoluteTime
                    times.append(time)
                }
            }

            let end = CFAbsoluteTimeGetCurrent()
            print("リクエスト終わり: ", end - start)
            dump(times)

            let failuresResult = await failures.get()
            dump(failuresResult)

            return results
        } // sendParallelCursorInfoRequest
    )
}

actor FailureNames {
    private var names: [String] = []
    func append(_ name: String) {
        names.append(name)
    }

    func get() -> [String] {
        names
    }
}
