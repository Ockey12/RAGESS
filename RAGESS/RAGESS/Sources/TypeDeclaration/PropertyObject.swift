//
//  PropertyObject.swift
//
//  
//  Created by Ockey12 on 2024/05/08
//  
//

import LanguageServerProtocol

public struct PropertyObject: DeclarationObject, PropertyOwner {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var properties: [PropertyObject] = []

    public init(
        name: String,
        fullPath: String,
        sourceCode: String = "",
        sourceRange: ClosedRange<Position>
    ) {
        self.name = name
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.sourceRange = sourceRange
    }
}