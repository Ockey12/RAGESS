//
//  PropertyOwner.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

public protocol PropertyOwner: DeclarationObject {
    var properties: [PropertyObject] { get set }
}
