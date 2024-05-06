//
//  TypeDeclSyntax.swift
//
//
//  Created by ockey12 on 2024/05/06.
//

import SwiftSyntax

protocol TypeDeclSyntax {}

extension StructDeclSyntax: TypeDeclSyntax {}

extension ClassDeclSyntax: TypeDeclSyntax {}

extension EnumDeclSyntax: TypeDeclSyntax {}

extension ActorDeclSyntax: TypeDeclSyntax {}
