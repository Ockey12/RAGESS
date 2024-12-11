//
//  NodeModel.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import DeclaredObject
import Foundation

struct NodeModel {
    let object: DeclaredObject
    var id: UUID {
        object.id
    }

    let parentID: UUID?
    var children: [Self] = []

    let frameWidth: CGFloat
    let bodyWidth: CGFloat
    let frameHeight: CGFloat

    var subtreeHeight: CGFloat {
        let verticalPadding = ComponentSizeValues.verticalPaddingBetweenCombinedDiagrams
        return max(
            frameHeight,
            children.reduce(0) { $0 + $1.subtreeHeight + verticalPadding } - verticalPadding
        )
    }

    init(
        object: DeclaredObject,
        parentID: UUID?,
        hasSuperClass: Bool,
        numberOfParentProtocols: Int,
        numberOfConformances: Int
    ) {
        self.object = object
        self.parentID = parentID

        let borderWidth = ComponentSizeValues.borderWidth
        let connectionHeight = ComponentSizeValues.connectionHeight
        let itemHeight = ComponentSizeValues.itemHeight
        let bottomPadding = ComponentSizeValues.bottomPaddingForLastText

        // set bodyWidth and frameWidth
        var allAnnotatedDecl = [object.declaration]
        // TODO: protocol and super class width
        allAnnotatedDecl.append(contentsOf: object.attributes.map { $0.declaration })
        allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.declaration })
        allAnnotatedDecl.append(contentsOf: object.variables.map { $0.declaration })
        allAnnotatedDecl.append(contentsOf: object.functions.map { $0.declaration })
        allAnnotatedDecl.append(contentsOf: object.cases.map { $0.declaration })
        print("")
        dump(allAnnotatedDecl)
        let bodyWidth = max(
            calculateMaxTextWidth(allAnnotatedDecl),
            ComponentSizeValues.bodyMinWidth
        )
        self.bodyWidth = bodyWidth
        frameWidth = bodyWidth
            + ComponentSizeValues.arrowTerminalWidth * 2
            + ComponentSizeValues.borderWidth

        // set frameHeight
        var frameHeight: CGFloat = itemHeight * 2 + bottomPadding
        if !object.attributes.isEmpty {
            frameHeight += connectionHeight + itemHeight * CGFloat(object.attributes.count) + bottomPadding
        }
        if hasSuperClass {
            frameHeight += connectionHeight + itemHeight + bottomPadding
        }
        if numberOfParentProtocols > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfParentProtocols) + bottomPadding
        }
        if numberOfConformances > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfConformances) + bottomPadding
        }
        if !object.initializers.isEmpty {
            frameHeight += connectionHeight + itemHeight * CGFloat(object.initializers.count) + bottomPadding
        }
        if !object.variables.isEmpty {
            frameHeight += connectionHeight + itemHeight * CGFloat(object.variables.count) + bottomPadding
        }
        if !object.functions.isEmpty {
            frameHeight += connectionHeight + itemHeight * CGFloat(object.functions.count) + bottomPadding
        }
        if !object.cases.isEmpty {
            frameHeight += connectionHeight + itemHeight * CGFloat(object.cases.count) + bottomPadding
        }
        frameHeight += connectionHeight + borderWidth
        self.frameHeight = frameHeight
    }
}
