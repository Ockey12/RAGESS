//
//  EnumObject.swift
//
//
//  Created by ockey12 on 2024/05/07.
//

import Dependencies
import Foundation

public struct EnumObject: TypeDeclaration {
    public let id: UUID
    public let name: String
    public let nameOffset: Int
    public var fullPath: String
    public var annotatedDecl: String
    public let sourceCode: String
    public let positionRange: ClosedRange<SourcePosition>
    public let offsetRange: ClosedRange<Int>

    public var cases: [CaseObject] = []

    public var initializers: [InitializerObject] = []
    public var variables: [VariableObject] = []
    public var functions: [FunctionObject] = []

    public var nestingProtocols: [ProtocolObject] = []
    public var nestingStructs: [StructObject] = []
    public var nestingClasses: [ClassObject] = []
    public var nestingEnums: [EnumObject] = []
    public var nestingActors: [ActorObject] = []

    public var descendantsID: [UUID] {
        var ids: [UUID] = [id]
        // `case` cannot nest other elements, so omit them.
        ids.append(contentsOf: initializers.flatMap { $0.descendantsID })
        ids.append(contentsOf: variables.flatMap { $0.descendantsID })
        ids.append(contentsOf: functions.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingProtocols.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingStructs.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingClasses.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingEnums.flatMap { $0.descendantsID })
        return ids
    }

    public var objectsThatCallThisObject: [DependencyObject] = []
    public var objectsThatAreCalledByThisObject: [DependencyObject] = []

    public init(
        name: String,
        nameOffset: Int,
        fullPath: String,
        annotatedDecl: String = "",
        sourceCode: String = "",
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

    public struct CaseObject: DeclarationObject {
        public let id: UUID
        public let name: String = "case"
        public let nameOffset: Int
        public var fullPath: String
        public var annotatedDecl: String
        public let sourceCode: String
        public let positionRange: ClosedRange<SourcePosition>
        public let offsetRange: ClosedRange<Int>

        // FIXME: Enum case cannot have variables and functions.
        public var variables: [VariableObject] = []
        public var functions: [FunctionObject] = []

        public var descendantsID: [UUID] {
            return []
        }

        public var objectsThatCallThisObject: [DependencyObject] = []
        public var objectsThatAreCalledByThisObject: [DependencyObject] = []

        public init(
            nameOffset: Int,
            fullPath: String,
            annotatedDecl: String = "",
            sourceCode: String,
            positionRange: ClosedRange<SourcePosition>,
            offsetRange: ClosedRange<Int>
        ) {
            @Dependency(\.uuid) var uuid
            id = uuid()
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
}