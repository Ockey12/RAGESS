//
//  SourcePosition.swift
//
//
//  Created by Ockey12 on 2024/05/12
//
//

public struct SourcePosition {
    let line: Int
    let utf8index: Int

    public init(line: Int, utf8index: Int) {
        self.line = line
        self.utf8index = utf8index
    }
}

extension SourcePosition: Comparable {
    public static func < (lhs: SourcePosition, rhs: SourcePosition) -> Bool {
        if lhs.line < rhs.line {
            return true
        } else if rhs.line < lhs.line {
            return false
        } else {
            return lhs.utf8index < rhs.utf8index
        }
    }
}
