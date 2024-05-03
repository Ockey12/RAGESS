//
//  DumpPackageClient.swift
//
//
//  Created by ockey12 on 2024/05/03.
//

import Dependencies
import DependenciesMacros
import Foundation
import XcodeObject

@DependencyClient
public struct DumpPackageClient {
    public var dumpPackage: @Sendable (
        _ currentDirectory: String
    ) async throws -> DumpPackageResponse
}

extension DumpPackageClient: DependencyKey {
    public static let liveValue: DumpPackageClient = .init(
        dumpPackage: { currentDirectory in
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.currentDirectoryPath = currentDirectory
            task.arguments = ["swift", "package", "dump-package"]

            let pipe = Pipe()
            task.standardOutput = pipe

            task.launch()
            task.waitUntilExit()

            let jsonString = pipe.fileHandleForReading.readDataToEndOfFile()
            let decoder = JSONDecoder()
            let data = try decoder.decode(DumpPackageResponse.self, from: jsonString)
            return data
        }
    )
}
