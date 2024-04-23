//
//  String+ByteOffset.swift
//
//
//  Created by ockey12 on 2024/04/23.
//

import LanguageServerProtocol
import LSPClient

public extension String {
    func getByteOffset(position: Position) throws -> Int {
        let lines = components(separatedBy: "\n")
        let row = position.line

        guard row >= 0,
              row < lines.count else {
            throw ByteOffsetError.invalidNumberOfLines
        }

        let line = lines[row]
        let column = position.utf16index

        guard column >= 0,
              column < line.lengthInEditor else {
            throw ByteOffsetError.invalidNumberOfColumns
        }

        return lengthInEditor
    }

    enum ByteOffsetError: Error {
        case invalidNumberOfLines
        case invalidNumberOfColumns
    }
}
