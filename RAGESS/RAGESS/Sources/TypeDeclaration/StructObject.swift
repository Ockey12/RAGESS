//
//  StructObject.swift
//
//
//  Created by ockey12 on 2024/05/06.
//

import LanguageServerProtocol

public struct StructObject: TypeDeclaration {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var nestingStructs: [StructObject] = []
    public var nestingClasses: [ClassObject] = []

    public var dependsOn: [any TypeDeclaration] = []
    public var dependsBy: [any TypeDeclaration] = []

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
