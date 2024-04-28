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
    public var getPath: @Sendable (_ xcodeprojPath: String) async throws -> String
}

extension BuildSettingsClient: DependencyKey {
    public static let liveValue: Self = .init { xcodeprojPath in
        #if DEBUG
            let startTime = CFAbsoluteTimeGetCurrent()
        #endif
        let task = Process()
        task.launchPath = "/usr/bin/xcodebuild"
        task.arguments = ["-project", xcodeprojPath, "-showBuildSettings"]

        let pipe = Pipe()
        task.standardOutput = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let lines = output.components(separatedBy: .newlines)
            for line in lines {
                if line.contains("BUILD_DIR = ") {
                    var derivedDataPath = line.replacingOccurrences(of: "BUILD_DIR = ", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    derivedDataPath = derivedDataPath.components(separatedBy: "/Build/")[0]
                    #if DEBUG
                        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                        print("DERIVED DATA PATH: \(derivedDataPath)")
                        print("TIME ELAPSED: \(timeElapsed)")
                        print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    #endif
                    return derivedDataPath
                }
            }
        }

        throw DerivedDataPathError.pathNotFound
    }
}

enum DerivedDataPathError: Error {
    case pathNotFound
}
