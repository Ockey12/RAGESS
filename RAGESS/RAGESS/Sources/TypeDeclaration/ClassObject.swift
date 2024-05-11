//
//  ClassObject.swift
//
//
//  Created by ockey12 on 2024/05/07.
//

import Dependency
import LanguageServerProtocol

public struct ClassObject: TypeDeclaration {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var nestingStructs: [StructObject] = []
    public var nestingClasses: [ClassObject] = []
    public var nestingEnums: [EnumObject] = []

    public var objectsOnWhichThisObjectDepends: [Dependency] = []
    public var objectsThatDependOnThisObject: [Dependency] = []

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
