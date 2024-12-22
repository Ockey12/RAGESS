//
//  InitialValue.swift
//
//
//  Created by Ockey12 on 2024/12/14
//
//

import Foundation

struct InitialValuesSample {
    private let a: Int = .init(1)

    private let b = try! returnString(first: 1, second: 2)

    private let c = try! returnString(
        first: 3,
        second: 4
    )

    private let d = 0

    private let e: (Int) -> String = { num in
        String(num)
    }

    private let f = [
        try! returnString(),
        "second"
    ]

    private let g = [
        try! returnString(
            first: 1,
            second: 2
        ),
        "second"
    ]

    private let h = [
        "first",
        "second"
    ]
}

func returnString() throws -> String {
    "third"
}

func returnString(first: Double, second: Float) throws -> String {
    String(first)
}
