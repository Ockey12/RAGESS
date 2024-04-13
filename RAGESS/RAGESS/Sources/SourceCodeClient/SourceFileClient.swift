//
//  SourceDirectoryClient.swift
//
//
//  Created by ockey12 on 2024/04/12.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct SourceFileClient {
    public var getSourceFiles: @Sendable (
        _ rootDirectoryPath: String,
        _ ignoredDirectories: [String]
    ) async throws -> [SourceFile]
}

extension SourceFileClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func getFilesContent(path: String, ignoredDirectories: [String]) -> [SourceFile] {
            let fileManager = FileManager.default
            guard let enumerator = fileManager.enumerator(atPath: path) else {
                return []
            }

            var sourceFiles = [SourceFile]()
            var isDirectory: ObjCBool = false
            let ignoredDirectoriesSet = Set(ignoredDirectories)

            while let filePath = enumerator.nextObject() as? String {
                let fullPath = (path as NSString).appendingPathComponent(filePath)
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) else {
                    continue
                }

                if isDirectory.boolValue,
                   ignoredDirectoriesSet.contains((filePath as NSString).lastPathComponent) {
                    enumerator.skipDescendants()
                    continue
                } else if filePath.hasSuffix(".swift") {
                    if let content = try? String(contentsOfFile: fullPath, encoding: .utf8) {
                        sourceFiles.append(.init(path: fullPath, content: content))
                    }
                }
            }

            return sourceFiles
        }

        return .init(
            getSourceFiles: { rootDirectoryPath, ignoredDirectories in
                #if DEBUG
                let startTime = CFAbsoluteTimeGetCurrent()
                let sourceFiles = getFilesContent(
                    path: rootDirectoryPath,
                    ignoredDirectories: ignoredDirectories
                )
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

                var numberOfLines = 0
                for sourceFile in sourceFiles {
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    print(sourceFile.path)
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    let lines = sourceFile.content.components(separatedBy: "\n")
                    numberOfLines += lines.count
                    for line in lines {
                        print(line)
                    }
                    print()
                }

                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                print("NUMBER OF LINES: \(numberOfLines)")
                print("TIME ELAPSED: \(timeElapsed)")
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")

                return sourceFiles
                #else
                let sourceFiles = getFilesContent(
                    path: rootDirectoryPath,
                    ignoredDirectories: ignoredDirectories
                )
                return sourceFiles
                #endif
            }
        )
    }()
}
