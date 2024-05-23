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
            var parentProtocolObject = ProtocolObject(
                name: "ParentProtocol",
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

            let inheritDependency = DependencyObject(
                kind: .protocolInheritance,
                callerObject: .init(
                    id: childProtocolObject.id,
                    keyPath: .protocol(\.self)
                ),
                definitionObject: .init(
                    id: parentProtocolObject.id,
                    keyPath: .protocol(\.self)
                )
            )

            parentProtocolObject.objectsThatCallThisObject.append(inheritDependency)
            childProtocolObject.objectsThatAreCalledByThisObject.append(inheritDependency)

            let allDeclarationObjects: [any DeclarationObject] = [
                parentProtocolObject,
                childProtocolObject
            ]

            guard let extractedParentProtocolObject = extractParentProtocolObject(
                by: childProtocolObject,
                allDeclarationObjects: allDeclarationObjects
            ) else {
                return XCTFail()
            }

            XCTAssertEqual(parentProtocolObject, extractedParentProtocolObject)
        }

    }
}
