//
//  ConvertedToStringEnumHolder.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/12.
//

import Foundation

struct ConvertedToStringEnumHolder: HaveChangeDate, Nameable, ConvertedAccessControllable, ConvertedTypeHolder, ConvertedNestable, ConvertedExtensionable {
    var changeDate = ""
    
    var name = ""
    var accessLevelIcon = ""
    var generics = [String]()
    var rawvalueType: String?
    var conformingProtocolNames = [String]()
    var typealiases = [String]()
    var initializers = [String]()
    var cases = [String]()
    var variables = [String]()
    var functions = [String]()
    
    var nestingConvertedToStringStructHolders = [ConvertedToStringStructHolder]()
    var nestingConvertedToStringClassHolders = [ConvertedToStringClassHolder]()
    var nestingConvertedToStringEnumHolders = [ConvertedToStringEnumHolder]()
    
    var extensions = [ConvertedToStringExtensionHolder]()
}

extension ConvertedToStringEnumHolder: Hashable {
    static func == (lhs: ConvertedToStringEnumHolder, rhs: ConvertedToStringEnumHolder) -> Bool {
        return (lhs.name == rhs.name) && (lhs.changeDate == rhs.changeDate)
    }

    var hashValue: Int {
        return self.name.hashValue
    }

    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        changeDate.hash(into: &hasher)
    }
}
