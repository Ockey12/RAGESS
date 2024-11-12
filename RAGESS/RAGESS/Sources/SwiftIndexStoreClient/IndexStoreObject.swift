//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/11/13
//  
//

import DeclaredObject

public struct IndexStoreObject {
    public let usr: String
    public let role: Role
    public let fullPath: String
    public let locationInXcode: LocationInXcode

    public enum Role: String {
        case definition
        case reference
    }

    public init(usr: String, role: Role, fullPath: String, line: Int64, column: Int64) {
        self.usr = usr
        self.role = role
        self.fullPath = fullPath
        locationInXcode = .init(line: Int(line), column: Int(column))
    }
}
