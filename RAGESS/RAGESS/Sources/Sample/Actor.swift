//
//  Actor.swift
//
//
//  Created by Ockey12 on 2024/10/30
//
//

private actor ActorSample: Identifiable {
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
