//
//  StructObject.swift
//
//
//  Created by ockey12 on 2024/05/06.
//

import LanguageServerProtocol

public struct StructObject: TypeDeclaration {
    public let name: String
    public let type: Type
    public let fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var dependsOn: Set<StructObject> = []
    public var dependsBy: Set<StructObject> = []

    public init(
        name: String,
        type: Type,
        fullPath: String,
        sourceCode: String,
        sourceRange: ClosedRange<Position>
    ) {
        self.name = name
        self.type = type
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.sourceRange = sourceRange
    }
}
