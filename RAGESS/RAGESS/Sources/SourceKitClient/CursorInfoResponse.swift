//
//  CursorInfoResponse.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

public struct CursorInfoResponse {
    public var name: String?
    public var kind: String?
    public var length: Int64?
    public var declLang: String?
    public var typeName: String?
    public var annotatedDecl: String?
    public var fullyAnnotatedDecl: String?
    public var filePath: String?
    public var moduleName: String?
    public var line: Int64?
    public var column: Int64?
    public var offset: Int64?
    public var USR: String?
    public var typeUSR: String?
    public var containerTypeUSR: String?
    public var reusingASTContext: Bool?

    public init() {}
}
