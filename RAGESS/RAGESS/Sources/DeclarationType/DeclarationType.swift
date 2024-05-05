//
//  DeclarationType.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import LanguageServerProtocol

public struct DeclarationType: Hashable {
    public let name: String
    public let type: Type
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    /// A set of types that the current type depends on.
    /// For example, the current type uses another type as a property, parameter, or return type.
    var dependsOn: Set<Self>

    /// A set of types that depend on the current type.
    /// For example, another type uses the current type as a property, parameter, or return type.
    var dependsBy: Set<Self>

    public init(
        name: String,
        type: Type,
        fullPath: String,
        sourceCode: String,
        sourceRange: ClosedRange<Position>,
        dependsOn: Set<Self>,
        dependsBy: Set<Self>
    ) {
        self.name = name
        self.type = type
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.sourceRange = sourceRange
        self.dependsOn = dependsOn
        self.dependsBy = dependsBy
    }
}
