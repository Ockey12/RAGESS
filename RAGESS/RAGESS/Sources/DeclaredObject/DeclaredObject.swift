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
    public var usrs: [String] {
        didSet {
            for i in attributes.indices {
                attributes[i].parentUSRs = usrs
            }
            for i in initializers.indices {
                initializers[i].parentUSRs = usrs
            }
            for i in variables.indices {
                variables[i].parentUSRs = usrs
            }
            for i in functions.indices {
                functions[i].parentUSRs = usrs
            }
            for i in cases.indices {
                cases[i].parentUSRs = usrs
            }
            for i in nestingStructs.indices {
                nestingStructs[i].parentUSRs = usrs
            }
            for i in nestingClasses.indices {
                nestingClasses[i].parentUSRs = usrs
            }
            for i in nestingEnums.indices {
                nestingEnums[i].parentUSRs = usrs
            }
            for i in nestingProtocols.indices {
                nestingProtocols[i].parentUSRs = usrs
            }
            for i in nestingActors.indices {
                nestingActors[i].parentUSRs = usrs
            }
        }
    }

    public var name: String
    public let nameOffset: Int
    public let fullPath: String
    public var annotatedDecl: String?
    public let sourceCode: String
    public let rangeInXcode: ClosedRange<LocationInXcode>
    public let offsetRange: ClosedRange<Int>
    public let kind: Kind

    public var attributes: [Self]

    public var initializers: [Self]
    public var variables: [Self]
    public var functions: [Self]
    public var cases: [Self]

    public var nestingStructs: [Self]
    public var nestingClasses: [Self]
    public var nestingEnums: [Self]
    public var nestingProtocols: [Self]
    public var nestingActors: [Self]

    public var withNestingTypes: [Self] {
        var types = [self]
        types.append(contentsOf: nestingStructs.flatMap { $0.withNestingTypes })
        types.append(contentsOf: nestingClasses.flatMap { $0.withNestingTypes })
        types.append(contentsOf: nestingEnums.flatMap { $0.withNestingTypes })
        types.append(contentsOf: nestingProtocols.flatMap { $0.withNestingTypes })
        types.append(contentsOf: nestingActors.flatMap { $0.withNestingTypes })
        return types
    }

    public var parentUSRs: [String]

    public var descendantsID: [UUID] {
        var ids: [UUID] = [id]

        ids.append(contentsOf: attributes.flatMap { $0.descendantsID })

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

    public var descendantsUSRs: [String] {
        var usrs: [String] = usrs

        usrs.append(contentsOf: attributes.flatMap { $0.descendantsUSRs })

        usrs.append(contentsOf: initializers.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: variables.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: functions.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: cases.flatMap { $0.descendantsUSRs })

        usrs.append(contentsOf: nestingStructs.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: nestingClasses.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: nestingEnums.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: nestingProtocols.flatMap { $0.descendantsUSRs })
        usrs.append(contentsOf: nestingActors.flatMap { $0.descendantsUSRs })
        return usrs
    }

    public private(set) var enclosingTypeNames: [String]

    public mutating func addOuterEnclosingTypeName(_ name: String) {
        enclosingTypeNames.insert(name, at: 0)
        for i in nestingStructs.indices {
            nestingStructs[i].addOuterEnclosingTypeName(name)
        }
        for i in nestingClasses.indices {
            nestingClasses[i].addOuterEnclosingTypeName(name)
        }
        for i in nestingEnums.indices {
            nestingEnums[i].addOuterEnclosingTypeName(name)
        }
        for i in nestingProtocols.indices {
            nestingProtocols[i].addOuterEnclosingTypeName(name)
        }
        for i in nestingActors.indices {
            nestingActors[i].addOuterEnclosingTypeName(name)
        }
    }

    public let declModifiers: [String]

    public var declaration: String {
        var declaration = declModifiers.joined(separator: " ")
        if !declModifiers.isEmpty {
            declaration += " "
        }
        switch kind {
        case .struct, .class, .enum, .protocol, .actor, .extension:
            declaration += kind.rawValue + " "
        case .function:
            declaration += "func "
        case .initializer, .variable, .case, .attribute:
            break
        }
        for enclosingTypeName in enclosingTypeNames {
            declaration += enclosingTypeName + "."
        }
        declaration += "\(name)"
        return declaration
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
        attributes: [Self] = [],
        initializers: [Self] = [],
        variables: [Self] = [],
        functions: [Self] = [],
        cases: [Self] = [],
        nestingStructs: [Self] = [],
        nestingClasses: [Self] = [],
        nestingEnums: [Self] = [],
        nestingProtocols: [Self] = [],
        nestingActors: [Self] = [],
        parentUSRs: [String] = [],
        enclosingTypeNames: [String] = [],
        declModifiers: [String] = []
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

        self.attributes = attributes

        self.initializers = initializers
        self.variables = variables
        self.functions = functions
        self.cases = cases
        self.nestingStructs = nestingStructs
        self.nestingClasses = nestingClasses
        self.nestingEnums = nestingEnums
        self.nestingProtocols = nestingProtocols
        self.nestingActors = nestingActors

        self.parentUSRs = parentUSRs
        self.enclosingTypeNames = enclosingTypeNames
        self.declModifiers = declModifiers
    }
}

public extension DeclaredObject {
    enum Kind: String {
        case `struct`
        case `class`
        case `enum`
        case `protocol`
        case `actor`

        case `extension`

        case initializer
        case variable
        case function
        case `case`

        case attribute
    }
}
