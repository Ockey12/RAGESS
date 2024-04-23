//
//  String+ByteOffsetTests.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import LanguageServerProtocol
import XCTest

@testable import SourceKitClient

final class ByteOffsetTests: XCTestCase {
    func test_endOfString() {
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

        do {
            let endOfStringPosition = target.lastPosition
            let offset = try target.getByteOffset(position: endOfStringPosition)
            XCTAssertEqual(offset, 241)
        } catch let error as String.ByteOffsetError {
            XCTFail("Error: \(error.localizedDescription)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_invalidNumberOfLines() {
        let target = "Swift"
        do {
            let invalidPosition = Position(line: 1, utf16index: 0)
            let offset = try target.getByteOffset(position: invalidPosition)
            XCTFail("Expected ByteOffsetError.invalidNumberOfLines")
        } catch let error as String.ByteOffsetError {
            XCTAssertEqual(error.localizedDescription, "Invalid number of lines. [Line: 1]")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_invalidNumberOfColumns() {
        let target = "Swift"
        do {
            let invalidPosition = Position(line: 0, utf16index: 6)
            let offset = try target.getByteOffset(position: invalidPosition)
            XCTFail("Expected ByteOffsetError.invalidNumberOfColumns")
        } catch let error as String.ByteOffsetError {
            XCTAssertEqual(error.localizedDescription, "Invalid number of columns. [Line: 0, Column: 6]")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
