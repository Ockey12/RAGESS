//
//  ClassHolderToStringConverter.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/13.
//

import Foundation

struct ClassHolderToStringConverter {
    func convertToString(classHolder: ClassHolder) -> ConvertedToStringClassHolder {
        var convertedHolder = ConvertedToStringClassHolder()
        
        convertedHolder.name = classHolder.name
        convertedHolder.accessLevelIcon = classHolder.accessLevel.icon
        
        // genericをString型に変換する
        let genericConverter = GenericHolderToStringConverter()
        let stringGenerics = genericConverter.convertToString(genericHolders: classHolder.generics)
        convertedHolder.generics = stringGenerics
        
        // スーパークラスを格納する
        convertedHolder.superClassName = classHolder.superClassName
        
        // protocolをString型に変換する
        for protocolName in classHolder.conformingProtocolNames {
            convertedHolder.conformingProtocolNames.append(protocolName)
        }
        
        // typealiasをString型に変換する
        let typealiasConverter = TypealiasHolderToStringConverter()
        let stringTypealiases = typealiasConverter.convertToString(typealiasHolders: classHolder.typealiases)
        convertedHolder.typealiases = stringTypealiases
        
        // initializerをString型に変換する
        let initializerConverter = InitializerHolderToStringConverter()
        let stringInitializers = initializerConverter.convertToString(initializerHolders: classHolder.initializers)
        convertedHolder.initializers = stringInitializers
        
        // variableをString型に変換する
        let variableConverter = VariableHolderToStringConverter()
        let stringVariables = variableConverter.convertToString(variableHolders: classHolder.variables)
        convertedHolder.variables = stringVariables
        
        // functionをString型に変換する
        let functionConverter = FunctionHolderToStringConverter()
        let stringFunctions = functionConverter.convertToString(functionHolders: classHolder.functions)
        convertedHolder.functions = stringFunctions
        
        // ネストしているStructHolderをConvertedToStringStructHolder型に変換する
        if 0 < classHolder.nestingStructs.count {
            let converter = StructHolderToStringConverter()
            for nestedStruct in classHolder.nestingStructs {
                let convertedContent = converter.convertToString(holder: nestedStruct)
                convertedHolder.nestingConvertedToStringStructHolders.append(convertedContent)
            }
        }
        
        // ネストしているClassHolderをString型に変換する
        if 0 < classHolder.nestingClasses.count {
            let converter = ClassHolderToStringConverter()
            for nestedClass in classHolder.nestingClasses {
                let convertedContent = converter.convertToString(classHolder: nestedClass)
                convertedHolder.nestingConvertedToStringClassHolders.append(convertedContent)
            }
        }
        
        // ネストしているEnumHolderをString型に変換する
        if 0 < classHolder.nestingEnums.count {
            let converter = EnumHolderToStringConverter()
            for nestedEnum in classHolder.nestingEnums {
                let convertedContent = converter.convertToString(enumHolder: nestedEnum)
                convertedHolder.nestingConvertedToStringEnumHolders.append(convertedContent)
            }
        }
        
        // ExtensionHolderをConvertedToStringExtensionHolder型に変換する
        if 0 < classHolder.extensions.count {
            let converter = ExtensionHolderToStringConverter()
            for extensionHolder in classHolder.extensions {
                let convertedContent = converter.convertToString(extensionHolder: extensionHolder)
                convertedHolder.extensions.append(convertedContent)
            }
        }
        
        return convertedHolder
    } // func convertToString(classHolder: ClassHolder) -> ConvertedToStringClassHolder
}
