//
//  File.swift
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
