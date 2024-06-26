//
//  ExtractSuperClassObjects.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import TypeDeclaration

func extractSuperClassObject(
    by subClassObject: ClassObject,
    allDeclarationObjects: [any DeclarationObject]
) -> ClassObject? {
    let classInheritanceDependency = subClassObject.objectsThatAreCalledByThisObject.first(where: { $0.kind == .classInheritance })

    guard let classInheritanceDependency else {
        return nil
    }
    return allDeclarationObjects.first(where: { $0.id == classInheritanceDependency.definitionObject.rootObjectID }) as? ClassObject
}
