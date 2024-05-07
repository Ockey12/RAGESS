//
//  DeclarationObject.swift
//
//  
//  Created by Ockey12 on 2024/05/08
//  
//

import LanguageServerProtocol

public protocol DeclarationObject {
    var name: String { get }
    var fullPath: String { get set }
    var sourceCode: String { get }
    var sourceRange: ClosedRange<Position> { get }
}
