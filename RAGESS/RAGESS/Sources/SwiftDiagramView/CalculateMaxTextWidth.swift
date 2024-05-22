//
//  CalculateMaxTextWidth.swift
//  
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import Foundation

func calculateMaxTextWidth(_ strings: [String]) -> CGFloat {
    var maxWidth: CGFloat = 0

    for string in strings {
        let width = string.systemSize50Width
        if maxWidth < width {
            maxWidth = width
        }
    }

    return maxWidth
}
