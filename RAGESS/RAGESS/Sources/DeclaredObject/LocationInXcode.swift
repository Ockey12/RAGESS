//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/11/13
//  
//

public struct LocationInXcode: Equatable {
    let line: Int
    let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

extension LocationInXcode: Comparable {
    public static func < (lhs: LocationInXcode, rhs: LocationInXcode) -> Bool {
        if lhs.line < rhs.line {
            return true
        } else if rhs.line < lhs.line {
            return false
        } else {
            return lhs.column < rhs.column
        }
    }
}
