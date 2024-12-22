//
//  LocationInXcode.swift
//
//
//  Created by Ockey12 on 2024/11/13
//
//

public struct LocationInXcode: Equatable {
    public let line: Int
    public let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

extension LocationInXcode: Comparable {
    public static func < (lhs: LocationInXcode, rhs: LocationInXcode) -> Bool {
        if lhs.line != rhs.line {
            return lhs.line < rhs.line
        }
        return lhs.column < rhs.column
    }
}
