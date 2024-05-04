//
//  DumpPackageClient.swift
//
//
//  Created by ockey12 on 2024/05/03.
//

import CommandClient
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
            @Dependency(CommandClient.self) var commandClient

            let jsonString = try commandClient.execute(
                launchPath: "/usr/bin/env",
                arguments: ["swift", "package", "dump-package"],
                currentDirectory: currentDirectory
            )

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
