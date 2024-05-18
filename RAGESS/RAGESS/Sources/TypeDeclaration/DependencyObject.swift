//
//  DependencyObject.swift
//
//
//  Created by Ockey12 on 2024/05/11
//
//

import Foundation

public struct DependencyObject {
    public init(callerObject: Object, definitionObject: Object) {
        self.callerObject = callerObject
        self.definitionObject = definitionObject
    }

    /// This object uses definitionObject as the type of a variable or a function argument.
    /// This object may be affected by changes in dependedObject.
    public var callerObject: Object

    /// This object is used by callerObject as the type of a variable or the type of a function argument.
    /// Changes to this object may affect the dependingObject.
    public var definitionObject: Object

    public struct Object {
        public init(id: UUID, keyPath: ObjectKeyPath, kind: Kind) {
            self.id = id
            self.keyPath = keyPath
            self.kind = kind
        }

        public let id: UUID
        public let keyPath: ObjectKeyPath
        public let kind: Kind

        public enum ObjectKeyPath {
            case `protocol`(PartialKeyPath<ProtocolObject>)
            case `struct`(PartialKeyPath<StructObject>)
            case `class`(PartialKeyPath<ClassObject>)
            case `enum`(PartialKeyPath<EnumObject>)
            case variable(PartialKeyPath<VariableObject>)
            case function(PartialKeyPath<FunctionObject>)
        }

        public enum Kind {
            case protocolInheritance
            case classInheritance
            case protocolConformance

            /// Call a property or method.
            case declarationReference

            /// Use as types of properties, arguments, etc.
            case identifierType
        }
    }
}
