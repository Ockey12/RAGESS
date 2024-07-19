//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/19
//  
//

import Foundation

struct NodeModel {
    let object: GenericTypeObject
    let children: [Self]

    let frameWidth: CGFloat
    let frameHeight: CGFloat
    let topLeadingPoint: CGPoint
}
