//
//  CursorInfoResponseKey.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

public enum CursorInfoResponseKeys {
    case name
    case kind
    case length
    case declLang
    case typeName
    case annotatedDecl
    case fullyAnnotatedDecl
    case filePath
    case moduleName
    case line
    case column
    case offset
    case USR
    case typeUSR
    case containerTypeUSR
    case reusingASTContext

    public init?(key: String) {
        switch key {
        case "key.name":
            self = .name
        case "key.kind":
            self = .kind
        case "key.length":
            self = .length
        case "key.decl_lang":
            self = .declLang
        case "key.typename":
            self = .typeName
        case "key.annotated_decl":
            self = .annotatedDecl
        case "key.fully_annotated_decl":
            self = .fullyAnnotatedDecl
        case "key.filepath":
            self = .filePath
        case "key.modulename":
            self = .moduleName
        case "key.line":
            self = .line
        case "key.column":
            self = .column
        case "key.offset":
            self = .offset
        case "key.usr":
            self = .USR
        case "key.typeusr":
            self = .typeUSR
        case "key.containertypeusr":
            self = .containerTypeUSR
        case "key.reusingastcontext":
            self = .reusingASTContext
        default:
            return nil
        }
    }

    public var key: String {
        switch self {
        case .name:
            "key.name"
        case .kind:
            "key.kind"
        case .length:
            "key.length"
        case .declLang:
            "key.decl_lang"
        case .typeName:
            "key.typename"
        case .annotatedDecl:
            "key.annotated_decl"
        case .fullyAnnotatedDecl:
            "key.fully_annotated_decl"
        case .filePath:
            "key.filepath"
        case .moduleName:
            "key.modulename"
        case .line:
            "key.line"
        case .column:
            "key.column"
        case .offset:
            "key.offset"
        case .USR:
            "key.usr"
        case .typeUSR:
            "key.typeusr"
        case .containerTypeUSR:
            "key.containertypeusr"
        case .reusingASTContext:
            "key.reusingastcontext"
        }
    }
}
