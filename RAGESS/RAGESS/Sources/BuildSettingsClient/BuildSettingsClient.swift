//
//  BuildSettingsClient.swift
//
//
//  Created by ockey12 on 2024/04/26.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BuildSettingsClient {
    public var getSettings: @Sendable (_ xcodeprojPath: String) async throws -> [String: String]
}

extension BuildSettingsClient: DependencyKey {
    public static let liveValue: Self = .init { xcodeprojPath in
        #if DEBUG
            let startTime = CFAbsoluteTimeGetCurrent()
        #endif
        let task = Process()
        task.launchPath = "/usr/bin/xcodebuild"
        task.arguments = ["-showBuildSettings", "-project", xcodeprojPath]

        let pipe = Pipe()
        task.standardOutput = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var settings: [String: String] = [:]
        if let output = String(data: data, encoding: .utf8) {
            let lines = output.components(separatedBy: .newlines)
            for line in lines {
                let components = line.components(separatedBy: " = ")
                guard components.count == 2 else {
                    continue
                }
                let key = components[0]
                let setting = components[1]
                settings[key] = setting
                #if DEBUG
                print("\(key): \(setting)")
                #endif
            }
        }

        #if DEBUG
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
        print("TIME ELAPSED: \(timeElapsed)")
        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
        #endif

        return settings
    }
}
