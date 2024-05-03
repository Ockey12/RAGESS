//
//  DumpPackageResponse.swift
//
//
//  Created by ockey12 on 2024/05/03.
//

import Foundation

public struct DumpPackageResponse: Decodable {
    let name: String
    let targets: [Target]

    struct Target: Decodable {
        let name: String
        let dependencies: [Dependency]

        struct Dependency: Decodable {
            let byName: [String?]?
            let product: [String?]?
        }
    }

    struct SourceControl: Decodable {
        let identity: String
    }
}
