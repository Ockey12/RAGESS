//
//  SourceFile.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import DeclaredObject
import Foundation

public struct SourceFile: Identifiable {
    public var id: String {
        fullPath
    }

    public let fullPath: String
    public let keyPathFromRootDirectory: WritableKeyPath<Directory, Self>
    public var name: String {
        NSString(string: fullPath).lastPathComponent
    }

    public var sourceCode: String
    public var declaredObjects: [DeclaredObject]

    public init(
        fullPath: String,
        keyPathFromRootDirectory: WritableKeyPath<Directory, Self>,
        sourceCode: String,
        declaredObjects: [DeclaredObject] = []
    ) {
        self.fullPath = fullPath
        self.keyPathFromRootDirectory = keyPathFromRootDirectory
        self.sourceCode = sourceCode
        self.declaredObjects = declaredObjects
    }
}
