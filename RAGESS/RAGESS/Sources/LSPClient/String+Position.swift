//
//  String+Position.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import Foundation
import LanguageServerProtocol

extension String {
    var lengthInEditor: Int {
        let utf8View = self.utf8
        var length = 0
        var i = utf8View.startIndex
        while i < utf8View.endIndex {
            let codeUnit = utf8View[i]
            if codeUnit & 0xC0 == 0x80 {
                i = utf8View.index(after: i)
            } else if codeUnit & 0xF0 == 0xF0 {
                length += 2
                i = utf8View.index(i, offsetBy: 3, limitedBy: utf8View.endIndex) ?? utf8View.endIndex
            } else {
                length += 1
                i = utf8View.index(after: i)
            }
        }
        return length
    }

    var lastPosition: Position {
        var lastLineIndex = self.components(separatedBy: "\n").count - 1
        let lastLine = self.components(separatedBy: "\n").last!
        let lastLineLength = lastLine.lengthInEditor
        return Position(line: lastLineIndex, utf16index: lastLineLength)
    }
}
