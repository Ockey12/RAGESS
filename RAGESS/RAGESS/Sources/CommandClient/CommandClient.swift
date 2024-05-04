//
//  CommandClient.swift
//
//
//  Created by ockey12 on 2024/05/04.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CommandClient {
    public var execute: @Sendable (
        _ launchPath: String,
        _ arguments: [String],
        _ currentDirectory: String?
    ) throws -> String
}

extension CommandClient: DependencyKey {
    public static let liveValue: CommandClient = .init(
        execute: { launchPath, arguments, currentDirectory in
            let process = Process()
            process.launchPath = launchPath
            process.arguments = arguments
            if let currentDirectory {
                process.currentDirectoryPath = currentDirectory
            }

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()

            guard let response = try pipe.fileHandleForReading.readToEnd() else {
                throw CommandClientError.cannotReadResponse
            }

            guard let responseString = String(data: response, encoding: .utf8) else {
                throw CommandClientError.cannotConvertResponseToString
            }

            return responseString
        }
    )
}

public enum CommandClientError: Error {
    case cannotReadResponse
    case cannotConvertResponseToString
}
