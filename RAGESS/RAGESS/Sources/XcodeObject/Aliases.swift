//
//  Aliases.swift
//
//
//  Created by Ockey12 on 2024/11/16
//
//

import DeclaredObject

public typealias FullPath = String
public typealias SourceFileTable = [FullPath: SourceFile]
public typealias USR = String
public typealias USRTable = [USR: WritableKeyPath<Directory, DeclaredObject>]
