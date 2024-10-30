//
//  Initializer.swift
//
//
//  Created by Ockey12 on 2024/10/31
//
//

private struct InitializerSample {
    init() {
        _ = 0
        func method() {}

        protocol NestedProtocol {}
        struct NestedStruct {}
        class NestedClass {}
        enum NestedEnum {}
        actor NestedActor {}
    }
}
