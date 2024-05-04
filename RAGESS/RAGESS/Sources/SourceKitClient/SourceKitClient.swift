//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import Dependencies
import DependenciesMacros
import SourceKittenFramework

@DependencyClient
public struct SourceKitClient {
    public var sendCursorInfoRequest: @Sendable (
        _ file: String,
        _ offset: Int,
        _ sourceFilePaths: [String],
        _ arguments: [String]
    ) async throws -> [String: SourceKitRepresentable]
}

extension SourceKitClient: DependencyKey {
    public static let liveValue: Self = .init(
        sendCursorInfoRequest: { file, offset, _, arguments in
//            #if DEBUG
//                let compilerArgumentsGenerator = CompilerArgumentsGenerator(
//                    derivedDataPath: "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz",
//                    xcodeprojPath: "/Users/onaga/RAGESS/RAGESS/RAGESS.xcodeproj",
//                    moduleName: "DebugView",
//                    sourceFilePaths: sourceFilePaths
//                )
//                print("Compiler Arguments")
//                for argument in compilerArgumentsGenerator.arguments {
//                    print(argument)
//                }
//                print("")
//                print(".build Path")
//                let buildPaths = compilerArgumentsGenerator.getBuildDirectoryPaths(in: "/Users/onaga/RAGESS/RAGESS/")
//                for path in buildPaths {
//                    print(path)
//                }
//            #endif

            let byteCount = ByteCount(offset)
            let request = Request.cursorInfo(file: file, offset: byteCount, arguments: arguments)
            let response = try await request.asyncSend()

//            #if DEBUG
//                for (key, value) in response {
//                    print("\(key): \(value)")
//                    print("  \(type(of: value))")
//                }
//            #endif

            return response
        }
    )
}
