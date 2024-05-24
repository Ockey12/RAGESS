//
//  ExtractParentProtocolObjects.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import TypeDeclaration

func extractParentProtocolObjects(
    by childProtocolObject: ProtocolObject,
    allDeclarationObjects: [any DeclarationObject]
) -> [ProtocolObject] {
    let protocolInheritanceDependencies = childProtocolObject.objectsThatAreCalledByThisObject.filter {
        $0.kind == .protocolInheritance
    }

    return protocolInheritanceDependencies.compactMap { dependency in
        allDeclarationObjects.first(where: { $0.id == dependency.definitionObject.rootObjectID }) as? ProtocolObject
    }
}
