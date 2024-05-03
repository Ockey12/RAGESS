//
//  PackageObject.swift
//
//
//  Created by ockey12 on 2024/05/03.
//

import Foundation

public struct PackageObject {
    public let name: String
    public let modules: [Module]

    public init(name: String, modules: [Module]) {
        self.name = name
        self.modules = modules
    }
}
