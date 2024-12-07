//
//  DetailKind.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

public enum DetailKind {
    case attribute
    case parentProtocol
    case superClass
    case protocolConformance
    case initializers
    case variables
    case functions
    case `case`
    case nestType

    var text: String {
        switch self {
        case .attribute:
            "Attribute"
        case .parentProtocol:
            "Parent Protocol"
        case .superClass:
            "Super Class"
        case .protocolConformance:
            "Conform"
        case .initializers:
            "Initializer"
        case .variables:
            "Variables"
        case .functions:
            "Functions"
        case .case:
            "Case"
        case .nestType:
            "Nest"
        }
    }
}
