//
//  SourceKitRequestObject.swift
//
//
//  Created by Ockey12 on 2024/10/29
//
//

import Foundation
import SourceKittenFramework
import TypeDeclaration

public struct SourceKitRequestObject {
//    public let sourceCode: String

    // There is no need to send multiple requests for the same offset.
//    public let offsets: Set<Int>

    public let rootObjectID: UUID
    public let keyPathForRootObject: WritableKeyPath<DeclaredObject, DeclaredObject>
    public let object: DeclaredObject
    public let argumentsGenerator: CompilerArgumentsGenerator

    public init(
        rootObjectID: UUID,
        keyPathForRootObject: WritableKeyPath<DeclaredObject, DeclaredObject>,
        object: DeclaredObject,
        argumentsGenerator: CompilerArgumentsGenerator
    ) {
        self.rootObjectID = rootObjectID
        self.keyPathForRootObject = keyPathForRootObject
        self.object = object
        self.argumentsGenerator = argumentsGenerator
    }
}

public struct SourceKitResponse {
    public let request: SourceKitRequestObject
    public let response: [String: SourceKitRepresentable]

    public init(request: SourceKitRequestObject, response: [String: SourceKitRepresentable]) {
        self.request = request
        self.response = response
    }
}
