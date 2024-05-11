//
//  DeclarationObject.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

import Dependency
import LanguageServerProtocol

public protocol DeclarationObject {
    var name: String { get }
    var fullPath: String { get set }
    var sourceCode: String { get }
    var sourceRange: ClosedRange<Position> { get }

    var objectsOnWhichThisObjectDepends: [Dependency] { get set }

    var objectsThatDependOnThisObject: [Dependency] { get set }
}
