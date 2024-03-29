//
//  SyntaxNodeType.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/11/18.
//

import Foundation

// visitPre()、visitPost()で検査するnode.syntaxNodeType
enum SyntaxNodeType {
    case declSyntax // 宣言のsyntaxNodeTypeの末尾に共通しているキーワード
    
    // struct
    case structDeclSyntax // structの宣言
    
    // class
    case classDeclSyntax // classの宣言
    
    // enum
    case enumDeclSyntax // enumの宣言
    case enumCaseElementSyntax // enumのcase
    case parameterClauseSyntax // caseの連想値
    
    // variable
    case variableDeclSyntax // variableの宣言
    case customAttributeSyntax // variableの@ Stateなど
    case identifierPatternSyntax // variableの名前
    case typeAnnotationSyntax // variableの型
    case initializerClauseSyntax // variableの初期値
    case codeBlockSyntax // willSet, didSet, get, set, functionの中身
    case accessorBlockSyntax // variableのwillSet, didSet, get, setをまとめるブロック
    
    // function
    case functionDeclSyntax // fanctionの宣言開始
    case functionParameterSyntax // functionの個々の引数
    case returnClauseSyntax // functionの返り値
    
    //protocol
    case protocolDeclSyntax // プロトコルの宣言
    case inheritedTypeListSyntax // プロトコルへの準拠
    case associatedtypeDeclSyntax // protocol内での連想型の宣言
    
    // initializer
    case initializerDeclSyntax // initializerの宣言
    
    // extension
    case extensionDeclSyntax // extensionの宣言
    
    // generics
    case genericParameterSyntax // genericsの型引数の宣言
    
    // opaque result type
    case constrainedSugarTypeSyntax // opaque result typeの宣言
    
    case arrayTypeSyntax // 配列の宣言
    case dictionaryTypeSyntax // 辞書の宣言
    case tupleTypeSyntax // タプルの宣言
    case optionalTypeSyntax // 配列などがオプショナルのとき、これにラップされている
    case typealiasDeclSyntax // typealiasの宣言
    
//    case declModifierSyntax // アクセスレベル そのまま抽出できるから考慮しなくて良い？
    
    var string: String {
        switch self {
        case .declSyntax:
            return "DeclSyntax"
        // struct
        case .structDeclSyntax:
            return "StructDeclSyntax"
        // class
        case .classDeclSyntax:
            return "ClassDeclSyntax"
        // enum
        case .enumDeclSyntax:
            return "EnumDeclSyntax"
        case .enumCaseElementSyntax:
            return "EnumCaseElementSyntax"
        case .parameterClauseSyntax:
            return "ParameterClauseSyntax"
        // variable
        case .variableDeclSyntax:
            return "VariableDeclSyntax"
        case .customAttributeSyntax:
            return "CustomAttributeSyntax"
        case .identifierPatternSyntax:
            return "IdentifierPatternSyntax"
        case .typeAnnotationSyntax:
            return "TypeAnnotationSyntax"
        case .initializerClauseSyntax:
            return "InitializerClauseSyntax"
        case .codeBlockSyntax:
            return "CodeBlockSyntax"
        case .accessorBlockSyntax:
            return "AccessorBlockSyntax"
        // function
        case .functionDeclSyntax:
            return "FunctionDeclSyntax"
        case .functionParameterSyntax:
            return "FunctionParameterSyntax"
        case .returnClauseSyntax:
            return "ReturnClauseSyntax"
        // protocol
        case .protocolDeclSyntax:
            return "ProtocolDeclSyntax"
        case .inheritedTypeListSyntax:
            return "InheritedTypeListSyntax"
        case .associatedtypeDeclSyntax:
            return "AssociatedtypeDeclSyntax"
        // initializer
        case .initializerDeclSyntax:
            return "InitializerDeclSyntax"
        // extension
        case .extensionDeclSyntax:
            return "ExtensionDeclSyntax"
        // generics
        case .genericParameterSyntax:
            return "GenericParameterSyntax"
        // opaque result type
        case .constrainedSugarTypeSyntax:
            return "ConstrainedSugarTypeSyntax"
            
        case .arrayTypeSyntax:
            return "ArrayTypeSyntax"
        case .dictionaryTypeSyntax:
            return "DictionaryTypeSyntax"
        case .tupleTypeSyntax:
            return "TupleTypeSyntax"
        case .optionalTypeSyntax:
            return "OptionalTypeSyntax"
        case .typealiasDeclSyntax:
            return "TypealiasDeclSyntax"
        }
    }
}
