//
//  TypeDeclaration.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import LanguageServerProtocol

public protocol TypeDeclaration: DeclarationObject {
    var nestingStructs: [StructObject] { get set }
    var nestingClasses: [ClassObject] { get set }
    var nestingEnums: [EnumObject] { get set }
}
