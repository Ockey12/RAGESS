//
//  ConvertedToStringStructHolder.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/12.
//

import Foundation

struct ConvertedToStringStructHolder: HaveChangeDate, Nameable, ConvertedAccessControllable, ConvertedTypeHolder, ConvertedNestable, ConvertedExtensionable {
    var changeDate = ""
    
    var name = ""
    var accessLevelIcon = ""
    var generics = [String]()
    var conformingProtocolNames = [String]()
    var typealiases = [String]()
    var initializers = [String]()
    var variables = [String]()
    var functions = [String]()

    var nestingConvertedToStringStructHolders = [ConvertedToStringStructHolder]()
    var nestingConvertedToStringClassHolders = [ConvertedToStringClassHolder]()
    var nestingConvertedToStringEnumHolders = [ConvertedToStringEnumHolder]()

    var extensions = [ConvertedToStringExtensionHolder]()
}

extension ConvertedToStringStructHolder: Hashable {
    static func == (lhs: ConvertedToStringStructHolder, rhs: ConvertedToStringStructHolder) -> Bool {
        return (lhs.name == rhs.name) && (lhs.changeDate == rhs.changeDate)
    }

    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        changeDate.hash(into: &hasher)
    }
}
