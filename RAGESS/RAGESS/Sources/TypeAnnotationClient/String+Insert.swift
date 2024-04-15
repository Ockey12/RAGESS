//
//  String+Insert.swift
//
//
//  Created by ockey12 on 2024/04/16.
//

import LanguageServerProtocol

extension String {
    mutating func insert(_ additionalString: String, into position: Position) {
        var lines = components(separatedBy: "\n")
        guard position.line >= 0, position.line < lines.count else {
            print("行数がおかしい")
            return
        }

        var line = lines[position.line]
        guard position.utf16index >= 0, position.utf16index <= line.lengthInEditor else {
            print("列がおかしい")
            return
        }

        let index = line.index(line.startIndex, offsetBy: position.utf16index)
        line.insert(contentsOf: additionalString, at: index)

        lines[position.line] = line
        self = lines.joined(separator: "\n")
    }
}
