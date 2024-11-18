//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/11/17
//  
//

public struct DependencyObject {
    public let calleeUSR: String
    public let callerUSR: String

    public init(calleeUSR: String, callerUSR: String) {
        self.calleeUSR = calleeUSR
        self.callerUSR = callerUSR
    }
}
