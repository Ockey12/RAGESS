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
    ) async throws -> PackageObject
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
            let modules = data.targets.map { target in
                let byNames = target.dependencies.compactMap { $0.byName?.compactMap { $0 }.first }
                let products = target.dependencies.compactMap { $0.product?.compactMap{ $0 }.first }
                return Module(name: target.name, internalDependencies: byNames, externalDependencies: products)
            }

            return PackageObject(name: data.name, modules: modules)
        }
    )
}
