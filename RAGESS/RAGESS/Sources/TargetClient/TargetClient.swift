//
//  TargetClient.swift
//
//
//  Created by ockey12 on 2024/05/01.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct TargetClient {
    public var getTarget: @Sendable () async throws -> String
}

extension TargetClient: DependencyKey {
    public static var liveValue: TargetClient = .init(
        getTarget: {
            let task = Process()
            task.launchPath = "/usr/bin/swift"
            task.arguments = ["-print-target-info"]

            let pipe = Pipe()
            task.standardOutput = pipe

            task.launch()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                fatalError()
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                fatalError()
            }
            guard let target = json["target"] as? [String: Any] else {
                fatalError()
            }
            guard let triple = target["triple"] as? String else {
                fatalError()
            }

            return triple.trimmingCharacters(in: .whitespaces)
        }
    )
}
