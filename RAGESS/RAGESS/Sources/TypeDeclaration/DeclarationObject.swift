//
//  DeclarationObject.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

import Dependency

public protocol DeclarationObject {
    var name: String { get }
    var fullPath: String { get set }
    var sourceCode: String { get }
    var positionRange: ClosedRange<SourcePosition> { get }
    var offsetRange: ClosedRange<Int> { get }

    var objectsOnWhichThisObjectDepends: [Dependency] { get set }

    var objectsThatDependOnThisObject: [Dependency] { get set }
}
