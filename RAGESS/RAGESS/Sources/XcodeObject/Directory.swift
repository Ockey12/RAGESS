//
//  Directory.swift
//
//
//  Created by ockey12 on 2024/04/28.
//

import Foundation

public struct Directory: Identifiable {
    public var id: String {
        path
    }

    public let path: String
    public var name: String {
        NSString(string: path).lastPathComponent
    }

    public let subDirectories: [Self]
    public let files: [SourceFile]
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
        path: String,
        subDirectories: [Self],
        files: [SourceFile],
        xcodeprojPaths: [String] = [],
        packageSwiftPath: String? = nil
    ) {
        self.path = path
        self.subDirectories = subDirectories
        self.files = files
        self.xcodeprojPaths = xcodeprojPaths
        self.packageSwiftPath = packageSwiftPath
    }
}
