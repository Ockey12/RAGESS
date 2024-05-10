//
//  PropertyObject.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

import LanguageServerProtocol

public struct VariableObject: DeclarationObject, VariableOwner, FunctionOwner {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var properties: [VariableObject] = []
    public var functions: [FunctionObject] = []

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
