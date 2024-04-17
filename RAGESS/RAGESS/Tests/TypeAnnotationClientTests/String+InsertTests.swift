//
//  String+InsertTests.swift
//
//
//  Created by ockey12 on 2024/04/17.
//

import LanguageServerProtocol
import XCTest

@testable import TypeAnnotationClient

final class String_InsertTests: XCTestCase {
    func test_insert_at_beginning() {
        var target = "is a sentence."
        let additionalString = "This "
        let position = Position(line: 0, utf16index: 0)
        target.insert(additionalString, into: position)
        XCTAssertEqual(target, "This is a sentence.")
    }
}
