//
//  Class.swift
//
//
//  Created by Ockey12 on 2024/10/30
//
//

import Foundation

private class ClassSample: SuperClass, Identifiable {
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

private class SuperClass {}
