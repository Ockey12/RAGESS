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
    public var descriptionJSONString: String?

    public init(
        path: String,
        subDirectories: [Self],
        files: [SourceFile],
        descriptionJSONString: String? = nil
    ) {
        self.path = path
        self.subDirectories = subDirectories
        self.files = files
        self.descriptionJSONString = descriptionJSONString
    }
}
