//
//  Struct.swift
//
//
//  Created by Ockey12 on 2024/10/30
//
//

import Foundation

private struct StructSample: Identifiable {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    func method() {}

    protocol NestedProtocol {}
    struct NestedStruct {}
    class NestedClass {}
    enum NestedEnum {}
    actor NestedActor {}
}
