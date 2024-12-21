//
//  IndexStoreObject.swift
//
//
//  Created by Ockey12 on 2024/11/13
//
//

import DeclaredObject

public struct IndexStoreObject: Equatable {
    public let usr: String
    public let roles: [Role]
    public let fullPath: String
    public let locationInXcode: LocationInXcode

    public enum Role: String {
        case definition
        case reference
        case baseOf
    }

    public init(usr: String, roles: [Role], fullPath: String, line: Int64, column: Int64) {
        self.usr = usr
        self.roles = roles
        self.fullPath = fullPath
        locationInXcode = .init(line: Int(line), column: Int(column))
    }
}
