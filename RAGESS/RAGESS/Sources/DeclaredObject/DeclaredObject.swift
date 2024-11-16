//
//  DeclaredObject.swift
//
//
//  Created by Ockey12 on 2024/11/13
//
//

import Dependencies
import Foundation

public struct DeclaredObject: Identifiable, Equatable {
    public let id: UUID
    public var usrs: [String]
    public let name: String
    public let nameOffset: Int
    public let fullPath: String
    public var annotatedDecl: String?
    public let sourceCode: String
    public let rangeInXcode: ClosedRange<LocationInXcode>
    public let offsetRange: ClosedRange<Int>
    public let kind: Kind

    public var initializers: [Self]
    public var variables: [Self]
    public var functions: [Self]
    public var cases: [Self]

    public var nestingStructs: [Self]
    public var nestingClasses: [Self]
    public var nestingEnums: [Self]
    public var nestingProtocols: [Self]
    public var nestingActors: [Self]

    public var descendantsID: [UUID] {
        var ids: [UUID] = [id]

        ids.append(contentsOf: initializers.flatMap { $0.descendantsID })
        ids.append(contentsOf: variables.flatMap { $0.descendantsID })
        ids.append(contentsOf: functions.flatMap { $0.descendantsID })
        ids.append(contentsOf: cases.flatMap { $0.descendantsID })

        ids.append(contentsOf: nestingStructs.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingClasses.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingEnums.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingProtocols.flatMap { $0.descendantsID })
        ids.append(contentsOf: nestingActors.flatMap { $0.descendantsID })

        return ids
    }

    public init(
        usrs: [String] = [],
        name: String,
        nameOffset: Int,
        fullPath: String,
        annotatedDecl: String? = nil,
        sourceCode: String,
        rangeInXcode: ClosedRange<LocationInXcode>,
        offsetRange: ClosedRange<Int>,
        kind: Kind,
        initializers: [Self] = [],
        variables: [Self] = [],
        functions: [Self] = [],
        cases: [Self] = [],
        nestingStructs: [Self] = [],
        nestingClasses: [Self] = [],
        nestingEnums: [Self] = [],
        nestingProtocols: [Self] = [],
        nestingActors: [Self] = []
    ) {
        self.usrs = usrs
        @Dependency(\.uuid) var uuid
        id = uuid()
        self.name = name
        self.nameOffset = nameOffset
        self.fullPath = fullPath
        self.annotatedDecl = annotatedDecl
        self.sourceCode = sourceCode
        self.rangeInXcode = rangeInXcode
        self.offsetRange = offsetRange
        self.kind = kind

        self.initializers = initializers
        self.variables = variables
        self.functions = functions
        self.cases = cases
        self.nestingStructs = nestingStructs
        self.nestingClasses = nestingClasses
        self.nestingEnums = nestingEnums
        self.nestingProtocols = nestingProtocols
        self.nestingActors = nestingActors
    }
}

public extension DeclaredObject {
    enum Kind: String {
        case `struct`
        case `class`
        case `enum`
        case `protocol`
        case `actor`

        case initializer
        case variable
        case function
        case `case`
    }
}
