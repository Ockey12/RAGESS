//
//  DetailKind.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

public enum DetailKind {
    case superClass
    case protocolConformance
    case initializers
    case variables
    case functions
    case `case`
    case nestType

    var text: String {
        switch self {
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
