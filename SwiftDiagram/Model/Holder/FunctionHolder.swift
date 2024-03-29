//
//  FunctionHolder.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/05.
//

import Foundation

struct FunctionHolder: Nameable {
    var name: String = ""
    var accessLevel: AccessLevel = .internal
    
    var isStatic = false
    var isOverride = false
    var isMutating = false
    
    var generics = [GenericHolder]()
    
    var parameters = [ParameterHolder]()

    var returnValue: ReturnValueHolder?
    
    struct ParameterHolder: Holder, Typeable {
        var externalName: String?
        var internalName: String?
        var haveInoutKeyword = false
        var isVariadic = false
        
        var variableKind: VariableKind = .literal
        var literalType: String?
        var arrayType: String?
        var dictionaryKeyType: String?
        var dictionaryValueType: String?
        var tupleTypes = [String]()
        
        var isOptionalType = false
        
        var initialValue: String?
    }
    
    struct ReturnValueHolder: Holder, Typeable {
        var variableKind: VariableKind = .literal
        var literalType: String?
        var arrayType: String?
        var dictionaryKeyType: String?
        var dictionaryValueType: String?
        var tupleTypes = [String]()
        var isOptional = false
        var conformedProtocolByOpaqueResultTypeOfReturnValue: String?
    }
}
