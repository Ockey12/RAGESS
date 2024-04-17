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

    func test_insertAtBeginning() {
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

    func test_insertAtNegativeColumnIndex() {
        var target = "This is an immutable string."
        let additionalString = "ABC"
        let position = Position(line: 0, utf16index: -1)
        target.insert(additionalString, into: position)
        XCTAssertEqual(target, "This is an immutable string.")
    }

    func test_insertAtLargerColumnIndex() {
        var target = "This is an immutable string."
        let additionalString = "ABC"
        let position = Position(line: 0, utf16index: 29)
        target.insert(additionalString, into: position)
        XCTAssertEqual(target, "This is an immutable string.")
    }

    func test_insertAtNegativeLineIndex() {
        var target = """
        This sentence is line 0.
        This sentence is line 1.
        This sentence is line 2.
        """
        let additionalString = "This sentence is negative line."
        let position = Position(line: -1, utf16index: 0)
        target.insert(additionalString, into: position)
        XCTAssertEqual(
            target,
            """
            This sentence is line 0.
            This sentence is line 1.
            This sentence is line 2.
            """
        )
    }

    func test_insertAtLargerLineIndex() {
        var target = """
        This sentence is line 0.
        This sentence is line 1.
        This sentence is line 2.
        """
        let additionalString = "This is a line index greater than the range."
        let position = Position(line: 3, utf16index: 0)
        target.insert(additionalString, into: position)
        XCTAssertEqual(
            target,
            """
            This sentence is line 0.
            This sentence is line 1.
            This sentence is line 2.
            """
        )
    }
}
