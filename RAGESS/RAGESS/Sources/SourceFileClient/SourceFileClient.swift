//
//  SourceFileClient.swift
//
//
//  Created by ockey12 on 2024/04/12.
//

import Dependencies
import DependenciesMacros
import Foundation
import XcodeObject

@DependencyClient
public struct SourceFileClient {
    public var getSourceFiles: @Sendable (
        _ rootDirectoryPath: String,
        _ ignoredDirectories: [String]
    ) async throws -> [SourceFile]
}

extension SourceFileClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func getDirectories(rootPath: String, ignoredDirectories: [String]) -> Directory? {
            let fileManager = FileManager.default
            guard let enumerator = fileManager.enumerator(atPath: rootPath) else {
                return nil
            }

            var subDirectories: [Directory] = []
            var files: [SourceFile] = []
            let ignoredDirectoriesSet = Set(ignoredDirectories)

            while let path = enumerator.nextObject() as? String {
                let fullPath = (rootPath as NSString).appendingPathComponent(path)
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) else {
                    continue
                }

                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) else {
                    continue
                }
                if isDirectory.boolValue {
                    let directoryName = NSString(string: fullPath).lastPathComponent
                    guard !ignoredDirectoriesSet.contains(directoryName) else {
                        continue
                    }
                    let subDirectory = getDirectories(rootPath: fullPath, ignoredDirectories: ignoredDirectories)
                    subDirectories.append(subDirectory)
                } else {
                    let content = try? String(contentsOfFile: fullPath)
                    let file = SourceFile(path: fullPath, content: content ?? "")
                    files.append(file)
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
