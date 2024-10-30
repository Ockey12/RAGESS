//
//  Protocol.swift
//
//  
//  Created by Ockey12 on 2024/10/30
//  
//

import Foundation

private protocol ProtocolSample: Identifiable {
    init (id: Int)

    var variable: Int { get set }

    func method()
}
