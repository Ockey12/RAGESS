//
//  BuildSettingsClient.swift
//
//
//  Created by ockey12 on 2024/04/26.
//

import CommandClient
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BuildSettingsClient {
    public var getSettings: @Sendable (_ xcodeprojPath: String) async throws -> [String: String]
}

extension BuildSettingsClient: DependencyKey {
    public static let liveValue: Self = .init { xcodeprojPath in
        @Dependency(CommandClient.self) var commandClient

        let response = try commandClient.execute(
            launchPath: "/usr/bin/xcodebuild",
            arguments: ["-showBuildSettings", "-project", xcodeprojPath],
            currentDirectory: nil
        )

        let lines = response.components(separatedBy: .newlines)
        var settings: [String: String] = [:]
        for line in lines {
            let components = line.components(separatedBy: " = ")
            guard components.count == 2 else {
                continue
            }
            let key = components[0].trimmingCharacters(in: .whitespaces)
            let setting = components[1]
            settings[key] = setting
        }

        return settings
    }
}
