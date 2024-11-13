//
//  SourceFileObject.swift
//
//  
//  Created by Ockey12 on 2024/11/13
//  
//

public struct SourceFileObject: Identifiable {
    public var id: String {
        fullPath
    }

    public let fullPath: String
    public let sourceCode: String
    public let declaredObjects: [DeclaredObject]

    public init(fullPath: String, sourceCode: String, declaredObjects: [DeclaredObject]) {
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.declaredObjects = declaredObjects
    }
}
