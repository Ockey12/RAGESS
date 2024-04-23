//
//  String+ByteOffsetTests.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import XCTest

@testable import SourceKitClient

final class ByteOffsetTests: XCTestCase {
    let target = """
    private struct Affected {
        let affected: Affecting = Affecting()
        let propertyCaller: Int = Affecting().property
        let methodCaller: Int = Affecting().getValue()

        func get() {
            let value: Int = affected.getValue()
        }
    }
    """
    func test_endOfString() {
        do {
            let endOfStringPosition = target.lastPosition
            print(endOfStringPosition)
            let offset = try target.getByteOffset(position: endOfStringPosition)
            XCTAssertEqual(offset, 241)
        } catch let error as String.ByteOffsetError {
            XCTFail("Error: \(error.localizedDescription)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
