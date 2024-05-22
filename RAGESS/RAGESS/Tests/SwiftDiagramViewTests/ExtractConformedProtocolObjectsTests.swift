//
//  ExtractConformedProtocolObjectsTests.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import Dependencies
import TypeDeclaration
import XCTest

@testable import SwiftDiagramView

final class ExtractConformedProtocolObjectsTests: XCTestCase {
    func test_extractConformedProtocolObject() async {
        withDependencies({
            $0.uuid = .incrementing
        }, operation: {
            var structObject = StructObject(
                name: "ConformingStruct",
                nameOffset: 0,
                fullPath: "",
                annotatedDecl: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            let protocolObject = ProtocolObject(
                name: "ConformedProtocol",
                nameOffset: 0,
                fullPath: "",
                annotatedDecl: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            let conformDependency = DependencyObject(
                kind: .protocolConformance,
                callerObject: .init(
                    id: structObject.id,
                    keyPath: .struct(\.self)
                ),
                definitionObject: .init(
                    id: protocolObject.id,
                    keyPath: .protocol(\.self)
                )
            )

            structObject.objectsThatAreCalledByThisObject.append(conformDependency)

            let allDeclarationObjects: [any DeclarationObject] = [
                structObject,
                protocolObject
            ]

            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: structObject,
                allDeclarationObjects: allDeclarationObjects
            )

            let protocolConformDependencies = structObject.objectsThatAreCalledByThisObject.filter { $0.kind == .protocolConformance }
            XCTAssertEqual(protocolConformDependencies, [conformDependency])

            _ = protocolConformDependencies.compactMap { dependency in
                allDeclarationObjects.first(where: { object in
                    print("object.id: \(object.id)")
                    print("dependency.definitionObject.id: \(dependency.definitionObject.id)")
                    return object.id == dependency.definitionObject.id
                }) as? ProtocolObject
            }

            XCTAssertEqual(conformedProtocolObjects, [protocolObject])
        })
    }
}
