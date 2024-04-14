//
//  SourceFile.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import Foundation

public struct SourceFile: Identifiable {
    public var id: String {
        path
    }

    public var path: String
    public var content: String

    public init(path: String, content: String) {
        self.path = path
        self.content = content
    }
}
