//
//  ExtractParentProtocolObjectsTests.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import Dependencies
import TypeDeclaration
import XCTest

@testable import SwiftDiagramView

final class ExtractParentProtocolObjectsTests: XCTestCase {
    func test_CanIdentifyParentProtocol() async {
        withDependencies {
            $0.uuid = .incrementing
        } operation: {
            var firstParentProtocolObject = ProtocolObject(
                name: "FirstParentProtocol",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            var secondParentProtocolObject = ProtocolObject(
                name: "SecondParentProtocol",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            var childProtocolObject = ProtocolObject(
                name: "ChildProtocol",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            let firstInheritDependency = DependencyObject(
                kind: .protocolInheritance,
                callerObject: .init(
                    id: childProtocolObject.id,
                    keyPath: .protocol(\.self)
                ),
                definitionObject: .init(
                    id: firstParentProtocolObject.id,
                    keyPath: .protocol(\.self)
                )
            )

            firstParentProtocolObject.objectsThatCallThisObject.append(firstInheritDependency)
            childProtocolObject.objectsThatAreCalledByThisObject.append(firstInheritDependency)

            let secondInheritDependency = DependencyObject(
                kind: .protocolInheritance,
                callerObject: .init(
                    id: childProtocolObject.id,
                    keyPath: .protocol(\.self)
                ),
                definitionObject: .init(
                    id: secondParentProtocolObject.id,
                    keyPath: .protocol(\.self)
                )
            )

            secondParentProtocolObject.objectsThatCallThisObject.append(secondInheritDependency)
            childProtocolObject.objectsThatAreCalledByThisObject.append(secondInheritDependency)

            let allDeclarationObjects: [any DeclarationObject] = [
                firstParentProtocolObject,
                secondParentProtocolObject,
                childProtocolObject
            ]

            let extractedParentProtocolObjects = extractParentProtocolObjects(
                by: childProtocolObject,
                allDeclarationObjects: allDeclarationObjects
            )

            XCTAssertEqual([firstParentProtocolObject, secondParentProtocolObject], extractedParentProtocolObjects)
        }
    }

    func test_Parent_ChildRelationshipDoesNotExist() async {
        withDependencies {
            $0.uuid = .incrementing
        } operation: {
            var protocolObject = ProtocolObject(
                name: "ChildProtocol",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            var otherProtocolObject = ProtocolObject(
                name: "FirstParentProtocol",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )

            let allDeclarationObjects: [any DeclarationObject] = [
                protocolObject,
                otherProtocolObject
            ]

            let extractedParentProtocolObjects = extractParentProtocolObjects(
                by: protocolObject,
                allDeclarationObjects: allDeclarationObjects
            )

            XCTAssertEqual([], extractedParentProtocolObjects)
        }
    }
}
