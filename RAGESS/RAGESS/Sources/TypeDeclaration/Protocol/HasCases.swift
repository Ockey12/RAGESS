//
//  File.swift
//
//
//  Created by Ockey12 on 2024/11/07
//
//

public protocol HasCases: TypeDeclaration {
    var cases: [EnumObject.CaseObject] { get set }
}
