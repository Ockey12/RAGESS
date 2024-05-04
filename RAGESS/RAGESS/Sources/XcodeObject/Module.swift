//
//  Module.swift
//
//
//  Created by ockey12 on 2024/05/03.
//

import Foundation

public struct Module {
    public let name: String
    let internalDependencies: [String]
    let externalDependencies: [String]

    public init(name: String, internalDependencies: [String], externalDependencies: [String]) {
        self.name = name
        self.internalDependencies = internalDependencies
        self.externalDependencies = externalDependencies
    }
}
