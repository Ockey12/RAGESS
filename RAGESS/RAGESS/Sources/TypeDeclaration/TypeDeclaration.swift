//
//  TypeDeclaration.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import LanguageServerProtocol

public protocol TypeDeclaration: DeclarationObject, PropertyOwner, FunctionOwner {
    var nestingStructs: [StructObject] { get set }
    var nestingClasses: [ClassObject] { get set }
    var nestingEnums: [EnumObject] { get set }

    /// A set of types that the current type depends on.
    /// For example, the current type uses another type as a property, parameter, or return type.
    var dependsOn: [any TypeDeclaration] { get set }

    /// A set of types that depend on the current type.
    /// For example, another type uses the current type as a property, parameter, or return type.
    var dependsBy: [any TypeDeclaration] { get set }
}
