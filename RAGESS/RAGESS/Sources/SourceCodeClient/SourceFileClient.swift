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
        @Sendable func getFilesPath(path: String, ignoredDirectories: [String]) -> [SourceFile] {
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
                let sourceFiles = getFilesPath(
                    path: rootDirectoryPath,
                    ignoredDirectories: ignoredDirectories
                )
                dump(sourceFiles)
                return sourceFiles
            }
        )
    }()
}
