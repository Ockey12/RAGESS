//
//  GenericTypeObject.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import Foundation
import TypeDeclaration

public enum GenericTypeObject: Equatable {
    case `struct`(StructObject)
    case `class`(ClassObject)
    case `enum`(EnumObject)
    case `protocol`(ProtocolObject)

    var id: UUID {
        switch self {
        case let .struct(structObject):
            structObject.id
        case let .class(classObject):
            classObject.id
        case let .enum(enumObject):
            enumObject.id
        case let .protocol(protocolObject):
            protocolObject.id
        }
    }

    var name: String {
        switch self {
        case let .struct(structObject):
            structObject.name
        case let .class(classObject):
            classObject.name
        case let .enum(enumObject):
            enumObject.name
        case let .protocol(protocolObject):
            protocolObject.name
        }
    }

    var objectsThatCallThisObject: [DependencyObject] {
        switch self {
        case let .struct(structObject):
            structObject.objectsThatCallThisObject
        case let .class(classObject):
            classObject.objectsThatCallThisObject
        case let .enum(enumObject):
            enumObject.objectsThatCallThisObject
        case let .protocol(protocolObject):
            protocolObject.objectsThatCallThisObject
        }
    }
}
