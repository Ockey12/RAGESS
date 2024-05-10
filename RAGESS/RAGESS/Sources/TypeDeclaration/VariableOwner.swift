//
//  PropertyOwner.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

public protocol VariableOwner: DeclarationObject {
    var properties: [VariableObject] { get set }
}
