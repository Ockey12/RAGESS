//
//  DeclarationObject.swift
//
//
//  Created by Ockey12 on 2024/05/08
//
//

import Foundation

public protocol DeclarationObject: Identifiable, Equatable {
    var id: UUID { get }
    var name: String { get }
    var nameOffset: Int { get }
    var fullPath: String { get set }
    var annotatedDecl: String { get set }
    var sourceCode: String { get }
    var positionRange: ClosedRange<SourcePosition> { get }
    var offsetRange: ClosedRange<Int> { get }

    var variables: [VariableObject] { get set }
    var functions: [FunctionObject] { get set }

    var descendantsID: [UUID] { get }

    var objectsThatCallThisObject: [DependencyObject] { get set }

    var objectsThatAreCalledByThisObject: [DependencyObject] { get set }
}
