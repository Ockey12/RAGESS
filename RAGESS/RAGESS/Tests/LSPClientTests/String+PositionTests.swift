//
//  String+PositionTests.swift
//
//
//  Created by ockey12 on 2024/04/19.
//

import LanguageServerProtocol
import XCTest

@testable import LSPClient

final class LengthInEditorTests: XCTestCase {
    func test_stringLength() {
        XCTAssertEqual("Swift".lengthInEditor, 5)
        XCTAssertEqual("Swift\n".lengthInEditor, 6)
    }

    func test_emojiLength() {
        XCTAssertEqual("🥹".lengthInEditor, 2)
        XCTAssertEqual("👨🏻‍🦱".lengthInEditor, 7)
        XCTAssertEqual("🧑‍🧑‍🧒‍🧒".lengthInEditor, 11)
    }
}

final class LastPositionTests: XCTestCase {
    func test_singleLine() {
        XCTAssertEqual(
            "Swift".lastPosition,
            Position(line: 0, utf16index: 5)
        )
    }

    func test_multipleLines() {
        XCTAssertEqual(
            "Objective-C\nSwift".lastPosition,
            Position(line: 1, utf16index: 5)
        )
        XCTAssertEqual(
            "Objective-C\nSwift\n".lastPosition,
            Position(line: 2, utf16index: 0)
        )
    }
}
