//
//  ExtractConformedProtocolObjects.swift
//
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import TypeDeclaration

func extractConformedProtocolObjects(by conformingObject: any Inheritable, allDeclarationObjects: [any DeclarationObject]) -> [ProtocolObject] {
    let protocolConformDependencies = conformingObject.objectsThatAreCalledByThisObject.filter { $0.kind == .protocolConformance }
    return protocolConformDependencies.compactMap { dependency in
        allDeclarationObjects.first(where: { $0.id == dependency.definitionObject.id }) as? ProtocolObject
    }
}
