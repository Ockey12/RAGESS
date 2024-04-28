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
    public var getXcodeObjects: @Sendable (
        _ rootDirectoryPath: String,
        _ ignoredDirectories: [String]
    ) async throws -> Directory
}

extension SourceFileClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func getDirectories(rootPath: String, ignoredDirectories: [String]) -> Directory {
            let fileManager = FileManager.default
            print(rootPath)

            var subDirectories: [Directory] = []
            var files: [SourceFile] = []
            var descriptionJSONString: String?
            let ignoredDirectoriesSet = Set(ignoredDirectories)
            var isDirectory: ObjCBool = false

            guard let paths = try? fileManager.contentsOfDirectory(atPath: rootPath) else {
                return Directory(path: rootPath, subDirectories: [], files: [])
            }

            for path in paths {
                let fullPath = NSString(string: rootPath).appendingPathComponent(path)
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
                } else if path.hasSuffix(".swift") {
                    guard let content = try? String(contentsOfFile: fullPath) else {
                        continue
                    }
                    let file = SourceFile(path: fullPath, content: content)
                    files.append(file)

                    if file.name == "Package.swift" {
                        let packagePath = NSString(string: fullPath).deletingLastPathComponent
                        let descriptionJSONPath = packagePath + "/.build/arm64-apple-macosx/debug/description.json"
                        guard let jsonString = try? String(contentsOfFile: descriptionJSONPath) else {
                            continue
                        }
                        descriptionJSONString = jsonString
                    }
                }
            }

            return Directory(
                path: rootPath,
                subDirectories: subDirectories,
                files: files,
                descriptionJSONString: descriptionJSONString
            )
        }

        return .init(
            getXcodeObjects: { rootDirectoryPath, ignoredDirectories in
                #if DEBUG
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let directory = getDirectories(
                        rootPath: rootDirectoryPath,
                        ignoredDirectories: ignoredDirectories
                    )
                    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

                    var numberOfLines = printDirectoryContents(directory)

                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    print("NUMBER OF LINES: \(numberOfLines)")
                    print("TIME ELAPSED: \(timeElapsed)")
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")

                    return directory
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

#if DEBUG
    extension SourceFileClient {
        static func printDirectoryContents(_ directory: Directory) -> Int {
            var numberOfLines = 0
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
            print(directory.path)
            print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")

            if let description = directory.descriptionJSONString {
                let lines = description.components(separatedBy: "\n")
                for line in lines {
                    print(line)
                }
                print()
            }

            for sourceFile in directory.files {
                print("*** \(sourceFile.path) ***")
                let lines = sourceFile.content.components(separatedBy: "\n")
                numberOfLines += lines.count
                for line in lines {
                    print(line)
                }
                print()
            }
            for subDirectory in directory.subDirectories {
                numberOfLines += printDirectoryContents(subDirectory)
            }

            return numberOfLines
        }
    }
#endif
