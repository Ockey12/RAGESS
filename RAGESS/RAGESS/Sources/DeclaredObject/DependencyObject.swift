//
//  DependencyObject.swift
//
//
//  Created by Ockey12 on 2024/11/17
//
//

public struct DependencyObject {
    public let calleeUSR: String
    public let callerUSRs: [String]

    public init(calleeUSR: String, callerUSRs: [String]) {
        self.calleeUSR = calleeUSR
        self.callerUSRs = callerUSRs
    }
}
