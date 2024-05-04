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

            #if DEBUG
                var debugText = launchPath
                debugText += arguments.joined(separator: " ")
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                print("CommandClient.execute()")
                print(debugText)
            #endif

            if let currentDirectory {
                process.currentDirectoryPath = currentDirectory
                #if DEBUG
                    print("IN: \(currentDirectory)")
                #endif
            }

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()
            #if DEBUG
                let startTime = CFAbsoluteTimeGetCurrent()
            #endif

            guard let response = try pipe.fileHandleForReading.readToEnd() else {
                throw CommandClientError.cannotReadResponse
            }

            guard let responseString = String(data: response, encoding: .utf8) else {
                throw CommandClientError.cannotConvertResponseToString
            }

            #if DEBUG
                print("RESPONSE")
                print(responseString)
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("TIME ELAPSED: \(timeElapsed)")
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
            #endif

            return responseString
        }
    )
}

public enum CommandClientError: Error {
    case cannotReadResponse
    case cannotConvertResponseToString
}
