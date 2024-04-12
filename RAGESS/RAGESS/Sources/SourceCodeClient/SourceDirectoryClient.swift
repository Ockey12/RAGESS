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
public struct SourceDirectoryClient {
    public var getSourceCode: @Sendable (
        _ rootDirectoryPath: String,
        _ ignoredDirectories: [String]
    ) async throws -> Void
}

extension SourceDirectoryClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func getFilesPath(path: String, ignoredDirectories: [String]) -> [String] {
            let fileManager = FileManager.default
            guard let enumerator = fileManager.enumerator(atPath: path) else {
                return []
            }

            var filePaths = [String]()
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
                    filePaths.append(fullPath)
                }
            }

            return filePaths
        }

        return .init(
            getSourceCode: { rootDirectoryPath, ignoredDirectories in
                let paths = getFilesPath(
                    path: rootDirectoryPath,
                    ignoredDirectories: ignoredDirectories
                )
                dump(paths)
            }
        )
    }()
}
