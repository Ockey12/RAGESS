//
//  Actor.swift
//
//  
//  Created by Ockey12 on 2024/10/30
//  
//

private actor RequestCoordinator {
    private var num: Int

    init(argument: Int) {
        num = argument
    }

    func method() {}

    struct NestedStruct {}
    class NestedClass {}
    enum NestedEnum {}
    actor NestedActor {}
}
