//
//  TypeDeclaration.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import LanguageServerProtocol

public protocol TypeDeclaration: Inheritable, Initializable, TypeNestable, HasHeader {}
