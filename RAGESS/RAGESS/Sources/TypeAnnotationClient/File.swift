//
//  TypeAnnotationClient.swift
//
//
//  Created by ockey12 on 2024/04/16.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct TypeAnnotationClient {
    public var setTypeAnnotation: @Sendable () async throws -> String
}
