//
//  InitializerObject.swift
//
//
//  Created by Ockey12 on 2024/05/19
//
//

import Dependencies
import Foundation

public struct InitializerObject: TypeNestable {
    public let id: UUID
    public let name: String
    public let nameOffset: Int
    public var fullPath: String
    public var annotatedDecl: String
    public let sourceCode: String
    public let positionRange: ClosedRange<SourcePosition>
    public let offsetRange: ClosedRange<Int>

    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var nestingProtocols: [ProtocolObject] = []
    public var nestingStructs: [StructObject] = []
    public var nestingClasses: [ClassObject] = []
    public var nestingEnums: [EnumObject] = []

    public var objectsThatCallThisObject: [DependencyObject] = []
    public var objectsThatAreCalledByThisObject: [DependencyObject] = []

    public init(
        name: String,
        nameOffset: Int,
        fullPath: String,
        sourceCode: String = "",
        positionRange: ClosedRange<SourcePosition>,
        offsetRange: ClosedRange<Int>
    ) {
        @Dependency(\.uuid) var uuid
        id = uuid()
        self.name = name
        self.nameOffset = nameOffset
        self.fullPath = fullPath
        annotatedDecl = name
        self.sourceCode = sourceCode
        self.positionRange = positionRange
        self.offsetRange = offsetRange
    }
}