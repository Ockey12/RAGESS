//
//  String+systemSize50Width.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import Foundation

extension String {
    var systemSize50Width: CGFloat {
        var width: CGFloat = 0
        for character in self {
            width += character.systemSize50Width
        }
        return width
    }
}
