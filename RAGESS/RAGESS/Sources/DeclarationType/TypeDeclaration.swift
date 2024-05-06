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
    var fullPath: String { get set }
    var sourceCode: String { get }
    var sourceRange: ClosedRange<Position> { get }

    /// A set of types that the current type depends on.
    /// For example, the current type uses another type as a property, parameter, or return type.
    var dependsOn: Set<Self> { get set }

    /// A set of types that depend on the current type.
    /// For example, another type uses the current type as a property, parameter, or return type.
    var dependsBy: Set<Self> { get set }
}