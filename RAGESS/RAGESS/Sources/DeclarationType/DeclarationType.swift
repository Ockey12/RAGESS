//
//  DeclarationType.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

public struct DeclarationType: Hashable {
    let name: String
    let type: Type
    let fullPath: String
    let sourceCode: String

    /// A set of types that the current type depends on.
    /// For example, the current type uses another type as a property, parameter, or return type.
    var dependsOn: Set<Self>

    /// A set of types that depend on the current type.
    /// For example, another type uses the current type as a property, parameter, or return type.
    var dependsBy: Set<Self>
}
