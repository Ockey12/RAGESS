//
//  Initializable.swift
//
//
//  Created by Ockey12 on 2024/05/19
//
//

public protocol Initializable: DeclarationObject {
    var initializers: [InitializerObject] { get set }
}
