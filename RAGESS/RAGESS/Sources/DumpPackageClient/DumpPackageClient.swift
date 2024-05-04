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
            let process = Process()
            process.launchPath = "/usr/bin/env"
            process.currentDirectoryPath = currentDirectory
            process.arguments = ["swift", "package", "dump-package"]

            print("DumpPackageClient.dumpPackage")
            print(currentDirectory)

            let pipe = Pipe()
            process.standardOutput = pipe

            try process.run()
            print("task.run()")

            guard let response = try pipe.fileHandleForReading.readToEnd() else {
                throw DumpPackageError.cannotReadData
            }
            guard let jsonString = String(data: response, encoding: .utf8) else {
                throw DumpPackageError.cannnotEncodingResponse
            }
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()
            let data = try decoder.decode(DumpPackageResponse.self, from: jsonData)
            let modules = data.targets.map { target in
                let byNames = target.dependencies.compactMap { $0.byName?.compactMap { $0 }.first }
                let products = target.dependencies.compactMap { $0.product?.compactMap { $0 }.first }
                return Module(name: target.name, internalDependencies: byNames, externalDependencies: products)
            }

            return PackageObject(name: data.name, modules: modules)
        }
    )
}

enum DumpPackageError: Error {
    case cannotReadData
    case cannnotEncodingResponse
}
