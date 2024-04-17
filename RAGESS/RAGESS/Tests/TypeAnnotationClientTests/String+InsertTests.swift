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
    // Note that `Position` starts counting lines and characters from 0.

    func test_insert_at_beginning() {
        var target = "is a sentence."
        let additionalString = "This "
        let position = Position(line: 0, utf16index: 0)
        target.insert(additionalString, into: position)
        XCTAssertEqual(target, "This is a sentence.")
    }

    func test_insertAtEndOfLine() {
        var target = "This is a"
        let additionalString = " sentence."
        let position = Position(line: 0, utf16index: 9)
        target.insert(additionalString, into: position)
        XCTAssertEqual(target, "This is a sentence.")
    }
}
