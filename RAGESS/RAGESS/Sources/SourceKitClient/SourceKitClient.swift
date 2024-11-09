//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import Dependencies
import DependenciesMacros
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
    ) async throws -> [SourceKitResponse]
}

extension SourceKitClient: DependencyKey {
    public static let liveValue: Self = .init(
        sendCursorInfoRequest: { file, offset, _, arguments in
            let byteCount = ByteCount(offset)
            let request = Request.cursorInfo(file: file, offset: byteCount, arguments: arguments)
            let response = try await request.asyncSend()

            return response
        },
        sendParallelCursorInfoRequest: { objects, allSourceFiles in
            let maxConcurrent = 20

            return try await withThrowingTaskGroup(of: SourceKitResponse.self) { group in
                var results = [SourceKitResponse]()

                for i in 0..<min(maxConcurrent, objects.count) {
                    let object = objects[i]
                    guard let sourceFile = allSourceFiles.first(where: { $0.path == object.object.fullPath }) else {
                        continue
                    }
                    guard let arguments = try? object.argumentsGenerator.generateArguments() else {
                        #if DEBUG
                            print("ERROR: \(#file) - \(#function): Could not generate arguments for SourceKit")
                        #endif
                        continue
                    }
                    let request = Request.cursorInfo(file: sourceFile.content, offset: ByteCount(object.object.nameOffset), arguments: arguments)
                    group.addTask {
                        let response = try await request.asyncSend()
                        return SourceKitResponse(request: object, response: response)
                    }
                }

                var nextIndex = maxConcurrent

                for try await response in group {
                    results.append(response)
                    if nextIndex < objects.count {
                        let object = objects[nextIndex]
                        guard let sourceFile = allSourceFiles.first(where: { $0.path == object.object.fullPath }) else {
                            continue
                        }
                        guard let arguments = try? object.argumentsGenerator.generateArguments() else {
                            #if DEBUG
                                print("ERROR: \(#file) - \(#function): Could not generate arguments for SourceKit")
                            #endif
                            continue
                        }
                        let request = Request.cursorInfo(file: sourceFile.content, offset: ByteCount(object.object.nameOffset), arguments: arguments)
                        group.addTask {
                            let response = try await request.asyncSend()
                            return SourceKitResponse(request: object, response: response)
                        }
                        nextIndex += 1
                    }
                }

                return results
            } // withThrowingTaskGroup
        } // sendParallelCursorInfoRequest
    )
}
