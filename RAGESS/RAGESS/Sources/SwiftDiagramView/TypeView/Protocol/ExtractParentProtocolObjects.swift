//
//  ExtractParentProtocolObjects.swift
//
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import TypeDeclaration

func extractParentProtocolObject(
    by childProtocolObject: ProtocolObject,
    allDeclarationObjects: [any DeclarationObject]
) -> ProtocolObject? {
    let protocolInheritanceDependency = childProtocolObject.objectsThatAreCalledByThisObject.first(where: { $0.kind == .protocolInheritance })

    guard let protocolInheritanceDependency else {
        return nil
    }
    return allDeclarationObjects.first(where: { $0.id == protocolInheritanceDependency.definitionObject.id }) as? ProtocolObject
}
