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
    var children: [Self] = []

    let frameWidth: CGFloat = 0
    let frameHeight: CGFloat = 0
    let topLeadingPoint: CGPoint = .zero
}
