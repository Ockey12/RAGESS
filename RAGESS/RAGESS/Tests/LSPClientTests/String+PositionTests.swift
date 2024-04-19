//
//  String+PositionTests.swift
//
//
//  Created by ockey12 on 2024/04/19.
//

import XCTest

@testable import LSPClient

final class LengthInEditorTests: XCTestCase {
    func test_emojiLength() {
        XCTAssertEqual("🥹".lengthInEditor, 2)
        XCTAssertEqual("👨🏻‍🦱".lengthInEditor, 7)
        XCTAssertEqual("🧑‍🧑‍🧒‍🧒".lengthInEditor, 11)
    }
}
