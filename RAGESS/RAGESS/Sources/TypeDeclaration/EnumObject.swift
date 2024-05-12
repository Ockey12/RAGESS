//
//  EnumObject.swift
//
//
//  Created by ockey12 on 2024/05/07.
//

import DependencyObject

public struct EnumObject: TypeDeclaration {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let positionRange: ClosedRange<SourcePosition>
    public let offsetRange: ClosedRange<Int>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var nestingStructs: [StructObject] = []
    public var nestingClasses: [ClassObject] = []
    public var nestingEnums: [EnumObject] = []

    public var objectsOnWhichThisObjectDepends: [DependencyObject] = []
    public var objectsThatDependOnThisObject: [DependencyObject] = []

    public init(
        name: String,
        fullPath: String,
        sourceCode: String = "",
        positionRange: ClosedRange<SourcePosition>,
        offsetRange: ClosedRange<Int>
    ) {
        self.name = name
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.positionRange = positionRange
        self.offsetRange = offsetRange
    }
}
