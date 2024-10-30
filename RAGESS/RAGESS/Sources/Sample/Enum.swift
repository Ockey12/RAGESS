//
//  Enum.swift
//
//  
//  Created by Ockey12 on 2024/10/30
//  
//

import Foundation

private enum EnumSample: Identifiable {
    var id: Int { 0 }

    case even
    case odd

    init(num: Int) {
        if num % 2 == 0 {
            self = .even
        } else {
            self = .odd
        }
    }

    func method() {}

    protocol NestedProtocol {}
    struct NestedStruct {}
    class NestedClass {}
    enum NestedEnum {}
    actor NestedActor {}
}
