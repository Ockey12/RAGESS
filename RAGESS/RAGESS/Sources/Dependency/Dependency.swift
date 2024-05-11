//
//  Dependency.swift
//
//  
//  Created by Ockey12 on 2024/05/11
//  
//

import LanguageServerProtocol

public struct Dependency {
    /// This object uses dependedObject as the type of a variable or a function argument.
    /// This object may be affected by changes in dependedObject.
    public var dependingObject: Object

    /// This object is used by dependingObject as the type of a variable or the type of a function argument.
    /// Changes to this object may affect the dependingObject.
    public var dependedObject: Object

    public struct Object {
        public let kind: Kind
        public let filePath: String
        public let position: Position
        public let offset: Int

        public enum Kind {
            case `struct`
            case `class`
            case `enum`
            case `variable`
            case `function`
        }
    }
}
