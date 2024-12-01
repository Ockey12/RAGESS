//
//  DependencyObject.swift
//
//
//  Created by Ockey12 on 2024/11/17
//
//

import SwiftIndexStoreObject

public struct DependencyObject {
    public let calleeUSR: String
    public let callerUSRs: [String]
    public let roles: [IndexStoreObject.Role]

    public init(calleeUSR: String, callerUSRs: [String], roles: [IndexStoreObject.Role]) {
        self.calleeUSR = calleeUSR
        self.callerUSRs = callerUSRs
        self.roles = roles
    }
}
