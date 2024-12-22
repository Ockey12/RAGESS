//
//  Directory.swift
//
//
//  Created by ockey12 on 2024/04/28.
//

import Foundation

public struct Directory: Identifiable, Equatable {
    public var id: String {
        fullPath
    }

    public let fullPath: String
    public let keyPathFromRootDirectory: WritableKeyPath<Self, Self>
    public var name: String {
        NSString(string: fullPath).lastPathComponent
    }

    public var subDirectories: [Self]
    public var files: [SourceFile]
    public let xcodeprojPaths: [String]
    public var allXcodeprojPathsUnderDirectory: [String] {
        var allPaths = subDirectories.map { $0.allXcodeprojPathsUnderDirectory }.flatMap { $0 }
        allPaths += xcodeprojPaths
        return allPaths
    }

    public let packageSwiftPath: String?
    public var allPackageSwiftPath: [String] {
        var allPaths = subDirectories.compactMap { $0.allPackageSwiftPath }.flatMap { $0 }
        if let path = packageSwiftPath {
            allPaths.append(path)
        }
        return allPaths
    }

    public var descriptionJSONString: String?

    public init(
        fullPath: String,
        keyPathFromRootDirectory: WritableKeyPath<Self, Self>,
        subDirectories: [Self],
        files: [SourceFile],
        xcodeprojPaths: [String] = [],
        packageSwiftPath: String? = nil
    ) {
        self.fullPath = fullPath
        self.keyPathFromRootDirectory = keyPathFromRootDirectory
        self.subDirectories = subDirectories
        self.files = files
        self.xcodeprojPaths = xcodeprojPaths
        self.packageSwiftPath = packageSwiftPath
    }
}
