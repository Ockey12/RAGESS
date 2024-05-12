//
//  VariableObject.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

import Dependency

public struct VariableObject: DeclarationObject, VariableOwner, FunctionOwner {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let positionRange: ClosedRange<SourcePosition>
    public let offsetRange: ClosedRange<Int>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var objectsOnWhichThisObjectDepends: [Dependency] = []
    public var objectsThatDependOnThisObject: [Dependency] = []

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
