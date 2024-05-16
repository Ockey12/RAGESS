//
//  FunctionObject.swift
//
//
//  Created by ockey12 on 2024/05/06.
//

import Dependencies
import Foundation

public struct FunctionObject: DeclarationObject, VariableOwner, FunctionOwner {
    public let id: UUID
    public let name: String
    public var fullPath: String
    public var annotatedDecl: String = ""
    public let sourceCode: String
    public let positionRange: ClosedRange<SourcePosition>
    public let offsetRange: ClosedRange<Int>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var objectsThatCallThisObject: [DependencyObject] = []
    public var objectsThatAreCalledByThisObject: [DependencyObject] = []

    public init(
        name: String,
        fullPath: String,
        sourceCode: String = "",
        positionRange: ClosedRange<SourcePosition>,
        offsetRange: ClosedRange<Int>
    ) {
        @Dependency(\.uuid) var uuid
        id = uuid()
        self.name = name
        self.fullPath = fullPath
        self.sourceCode = sourceCode
        self.positionRange = positionRange
        self.offsetRange = offsetRange
    }
}
