//
//  Dependency.swift
//
//  
//  Created by Ockey12 on 2024/05/11
//  
//

import LanguageServerProtocol

public struct Dependency {
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
