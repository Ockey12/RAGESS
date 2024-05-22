//
//  DetailKind.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

public enum DetailKind {
    case initializers
    case variables
    case functions
    case `case`
    case nestType

    var text: String {
        switch self {
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
