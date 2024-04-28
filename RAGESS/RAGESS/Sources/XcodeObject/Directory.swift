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

    public var subDirectories: [Self]
    public var files: [SourceFile]
    public var xcodeprojPaths: [String]
    public var allXcodeprojPathsUnderDirectory: [String] {
        var allPaths = subDirectories.map { $0.allXcodeprojPathsUnderDirectory }.flatMap { $0 }
        allPaths += xcodeprojPaths
        return allPaths
    }

    public var descriptionJSONString: String?

    public init(
        path: String,
        subDirectories: [Self],
        files: [SourceFile],
        xcodeprojPaths: [String] = [],
        descriptionJSONString: String? = nil
    ) {
        self.path = path
        self.subDirectories = subDirectories
        self.files = files
        self.xcodeprojPaths = xcodeprojPaths
        self.descriptionJSONString = descriptionJSONString
    }
}
