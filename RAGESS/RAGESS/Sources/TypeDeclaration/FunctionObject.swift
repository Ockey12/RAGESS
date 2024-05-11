//
//  FunctionObject.swift
//
//
//  Created by ockey12 on 2024/05/06.
//

import Dependency
import LanguageServerProtocol

public struct FunctionObject: DeclarationObject, VariableOwner, FunctionOwner {
    public let name: String
    public var fullPath: String
    public let sourceCode: String
    public let sourceRange: ClosedRange<Position>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

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
