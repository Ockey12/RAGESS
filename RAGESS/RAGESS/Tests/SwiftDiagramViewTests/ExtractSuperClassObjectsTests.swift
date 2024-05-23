//
//  ExtractSuperClassObjectsTests.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import Dependencies
import TypeDeclaration
import XCTest

@testable import SwiftDiagramView

final class ExtractSuperClassObjectsTests: XCTestCase {
    func test_extractSuperClassObject() async {
        withDependencies(
            {
                $0.uuid = .incrementing
            },
            operation: {
                var superClassObject = ClassObject(
                    name: "SuperClass",
                    nameOffset: 0,
                    fullPath: "",
                    annotatedDecl: "",
                    positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                    offsetRange: 0 ... 1
                )

                var subClassObject = ClassObject(
                    name: "SubClass",
                    nameOffset: 0,
                    fullPath: "",
                    annotatedDecl: "",
                    positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                    offsetRange: 0 ... 1
                )

                let inheritDependency = DependencyObject(
                    kind: .classInheritance,
                    callerObject: .init(
                        id: subClassObject.id,
                        keyPath: .class(\.self)
                    ),
                    definitionObject: .init(
                        id: superClassObject.id,
                        keyPath: .class(\.self)
                    )
                )

                superClassObject.objectsThatCallThisObject.append(inheritDependency)
                subClassObject.objectsThatAreCalledByThisObject.append(inheritDependency)

                let allDeclarationObjects: [any DeclarationObject] = [
                    superClassObject,
                    subClassObject
                ]

                guard let extractedSuperClassObject = extractSuperClassObject(
                    by: subClassObject,
                    allDeclarationObjects: allDeclarationObjects
                ) else {
                    return XCTFail()
                }

                XCTAssertEqual(superClassObject, extractedSuperClassObject)
            }
        )
    }
}
