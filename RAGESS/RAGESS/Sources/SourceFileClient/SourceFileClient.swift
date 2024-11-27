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
    public var getRootDirectory: @Sendable (
        _ rootDirectoryPath: String,
        _ ignoredDirectories: [String]
    ) throws -> Directory
}

extension SourceFileClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func getDirectories(
            rootPath: String,
            keyPathFromRootDirectory: WritableKeyPath<Directory, Directory>,
            ignoredDirectories: [String]
        ) -> Directory {
            let fileManager = FileManager.default
            #if DEBUG
            print(rootPath)
            #endif

            var subDirectories: [Directory] = []
            var files: [SourceFile] = []
            var xcodeprojPaths: [String] = []
            var packageSwiftPath: String?
            let ignoredDirectoriesSet = Set(ignoredDirectories)
            var isDirectory: ObjCBool = false

            guard let paths = try? fileManager.contentsOfDirectory(atPath: rootPath) else {
                return Directory(
                    fullPath: rootPath,
                    keyPathFromRootDirectory: keyPathFromRootDirectory,
                    subDirectories: [],
                    files: []
                )
            }

            var subDirectoryIndex = 0
            var fileIndex = 0
            for path in paths {
                let fullPath = NSString(string: rootPath).appendingPathComponent(path)
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) else {
                    continue
                }

                if isDirectory.boolValue {
                    let directoryName = NSString(string: fullPath).lastPathComponent
                    if directoryName.hasSuffix(".xcodeproj") {
                        xcodeprojPaths.append(fullPath)
                    }
                    guard !ignoredDirectoriesSet.contains(directoryName) else {
                        continue
                    }

                    let keyPath = keyPathFromRootDirectory.appending(path: \Directory.subDirectories[subDirectoryIndex])
                    subDirectoryIndex += 1
                    let subDirectory = getDirectories(
                        rootPath: fullPath,
                        keyPathFromRootDirectory: keyPath,
                        ignoredDirectories: ignoredDirectories
                    )
                    subDirectories.append(subDirectory)
                } else if path.hasSuffix(".swift") {
                    guard let content = try? String(contentsOfFile: fullPath) else {
                        continue
                    }

                    let keyPath = keyPathFromRootDirectory.appending(path: \Directory.files[fileIndex])
                    fileIndex += 1
                    let file = SourceFile(
                        fullPath: fullPath,
                        keyPathFromRootDirectory: keyPath,
                        sourceCode: content
                    )
                    files.append(file)

                    if file.name == "Package.swift" {
                        packageSwiftPath = fullPath
                    }
                }
            }

            return Directory(
                fullPath: rootPath,
                keyPathFromRootDirectory: \Directory.self,
                subDirectories: subDirectories,
                files: files,
                xcodeprojPaths: xcodeprojPaths,
                packageSwiftPath: packageSwiftPath
            )
        }

        return .init(
            getRootDirectory: { rootDirectoryPath, ignoredDirectories in
                #if DEBUG
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let rootDirectory = getDirectories(
                        rootPath: rootDirectoryPath,
                        keyPathFromRootDirectory: \Directory.self,
                        ignoredDirectories: ignoredDirectories
                    )
                    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    print("NUMBER OF LINES: \(totalLines(in: rootDirectory))")
                    print("TIME ELAPSED: \(timeElapsed)")
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")

                    return rootDirectory
                #else
                    let rootDirectory = getRootDirectory(
                        rootPath: rootDirectoryPath,
                        ignoredDirectories: ignoredDirectories
                    )
                    return rootDirectory
                #endif
            }
        )
    }()
}

#if DEBUG
    extension SourceFileClient {
        static func totalLines(in directory: Directory) -> Int {
            var numberOfLines = 0
            
            for file in directory.files {
                numberOfLines += countLines(in: file)
            }

            for subDirectory in directory.subDirectories {
                numberOfLines += totalLines(in: subDirectory)
            }

            return numberOfLines
        }

        static func countLines(in file: SourceFile) -> Int {
            var numberOfLines = 0
            let sourceCode = file.sourceCode
            var currentIndex = sourceCode.startIndex
            var isInStringLiteral = false

            while currentIndex < sourceCode.endIndex {
                let currentChar = sourceCode[currentIndex]

                if currentChar == "\"" {
                    isInStringLiteral.toggle()
                    currentIndex = sourceCode.index(after: currentIndex)
                    continue
                }

                if currentChar == "\n" && !isInStringLiteral {
                    numberOfLines += 1
                }

                currentIndex = sourceCode.index(after: currentIndex)
            }

            return numberOfLines
        }
    }
#endif
