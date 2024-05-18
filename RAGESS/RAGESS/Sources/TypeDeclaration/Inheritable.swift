//
//  Inheritable.swift
//
//
//  Created by Ockey12 on 2024/05/18
//
//

public protocol Inheritable: DeclarationObject {
    // Used to perform `cursorinfo` requests for protocols and classes that this type inherits.
    var inheritOffsets: [Int] { get set }
}
