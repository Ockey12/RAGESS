//
//  String+Position.swift
//
//
//  Created by ockey12 on 2024/04/14.
//

import Foundation
import LanguageServerProtocol

public extension String {
    var lengthInEditor: Int {
        utf16.count
    }

    var lastPosition: Position {
        let lastLineIndex = components(separatedBy: "\n").count - 1
        let lastLine = components(separatedBy: "\n").last!
        let lastLineLength = lastLine.lengthInEditor
        return Position(line: lastLineIndex, utf16index: lastLineLength)
    }
}
