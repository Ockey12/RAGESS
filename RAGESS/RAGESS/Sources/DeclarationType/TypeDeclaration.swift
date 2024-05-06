//
//  DeclarationType.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import LanguageServerProtocol

public protocol TypeDeclaration: Hashable {
    var name: String { get }
    var type: Type { get }
    var fullPath: String { get }
    var sourceCode: String { get }
    var sourceRange: ClosedRange<Position> { get }

    /// A set of types that the current type depends on.
    /// For example, the current type uses another type as a property, parameter, or return type.
    var dependsOn: Set<Self> { get }

    /// A set of types that depend on the current type.
    /// For example, another type uses the current type as a property, parameter, or return type.
    var dependsBy: Set<Self> { get }

//    public init(
//        name: String,
//        type: Type,
//        fullPath: String,
//        sourceCode: String,
//        sourceRange: ClosedRange<Position>,
//        dependsOn: Set<Self>,
//        dependsBy: Set<Self>
//    ) {
//        self.name = name
//        self.type = type
//        self.fullPath = fullPath
//        self.sourceCode = sourceCode
//        self.sourceRange = sourceRange
//        self.dependsOn = dependsOn
//        self.dependsBy = dependsBy
//    }
}
