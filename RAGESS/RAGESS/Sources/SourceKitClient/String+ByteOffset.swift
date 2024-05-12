//
//  String+ByteOffset.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

// import Foundation
// import LanguageServerProtocol
// import LSPClient
//
// public extension String {
//    func getByteOffset(position: Position) throws -> Int {
//        let lines = components(separatedBy: "\n")
//        let row = position.line
//
//        guard row >= 0,
//              row < lines.count else {
//            throw ByteOffsetError.invalidNumberOfLines(line: row)
//        }
//
//        let line = lines[row]
//        let column = position.utf16index
//
//        guard column >= 0,
//              column <= line.lengthInEditor else {
//            throw ByteOffsetError.invalidNumberOfColumns(line: row, column: column)
//        }
//
//        return lengthInEditor
//    }
//
//    enum ByteOffsetError: LocalizedError {
//        case invalidNumberOfLines(line: Int)
//        case invalidNumberOfColumns(line: Int, column: Int)
//
//        public var errorDescription: String? {
//            switch self {
//            case let .invalidNumberOfLines(line):
//                return "Invalid number of lines. [Line: \(line)]"
//            case let .invalidNumberOfColumns(line, column):
//                return "Invalid number of columns. [Line: \(line), Column: \(column)]"
//            }
//        }
//    }
// }
