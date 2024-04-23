//
//  CursorInfoResponse.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

public struct CursorInfoResponse {
    public var name: String?
    public var kind: String?
    public var length: Int?
    public var declLang: String?
    public var typeName: String?
    public var annotatedDecl: String?
    public var fullyAnnotatedDecl: String?
    public var filePath: String?
    public var moduleName: String?
    public var line: Int?
    public var column: Int?
    public var offset: Int?
    public var USR: String?
    public var typeUSR: String?
    public var containerTypeUSR: String?
    public var reusingASTContext: String?

    public init() {}
}
