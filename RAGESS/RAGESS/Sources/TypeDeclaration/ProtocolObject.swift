//
//  ProtocolObject.swift
//
//
//  Created by Ockey12 on 2024/05/18
//
//

import Dependencies
import Foundation

public struct ProtocolObject: Inheritable, Initializable, HasHeader {
    public var id: UUID
    public var name: String
    public var nameOffset: Int
    public var fullPath: String
    public var annotatedDecl: String
    public var sourceCode: String
    public var positionRange: ClosedRange<SourcePosition>
    public var offsetRange: ClosedRange<Int>

    public var initializers: [InitializerObject] = []
    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var objectsThatCallThisObject: [DependencyObject] = []
    public var objectsThatAreCalledByThisObject: [DependencyObject] = []

    public init(
        name: String,
        nameOffset: Int,
        fullPath: String,
        annotatedDecl: String = "",
        sourceCode: String,
        positionRange: ClosedRange<SourcePosition>,
        offsetRange: ClosedRange<Int>
    ) {
        @Dependency(\.uuid) var uuid
        id = uuid()
        self.name = name
        self.nameOffset = nameOffset
        self.fullPath = fullPath

        if annotatedDecl == "" {
            self.annotatedDecl = name
        } else {
            self.annotatedDecl = annotatedDecl
        }

        self.sourceCode = sourceCode
        self.positionRange = positionRange
        self.offsetRange = offsetRange
    }
}
