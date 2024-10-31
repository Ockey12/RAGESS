//
//  NodeModel.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import Foundation
import TypeDeclaration

struct NodeModel {
    let object: GenericTypeObject
    var id: UUID {
        object.id
    }

    let parentID: UUID?
    var children: [Self] = []

    let frameWidth: CGFloat
    let bodyWidth: CGFloat
    let frameHeight: CGFloat

    var subtreeHeight: CGFloat {
        max(
            frameHeight,
            children.reduce(0) { $0 + $1.subtreeHeight + verticalPadding } - verticalPadding
        )
    }

    init(
        object: GenericTypeObject,
        parentID: UUID?,
        allDeclarationObjects: [any DeclarationObject]
    ) {
        self.object = object
        self.parentID = parentID

        let borderWidth = ComponentSizeValues.borderWidth
        let connectionHeight = ComponentSizeValues.connectionHeight
        let itemHeight = ComponentSizeValues.itemHeight
        let bottomPadding = ComponentSizeValues.bottomPaddingForLastText

        var hasSuperClass = false
        var numberOfParentProtocols = 0
        var numberOfConformances = 0
        var numberOfInitializers = 0
        var numberOfCases = 0
        var numberOfVariables = 0
        var numberOfFunctions = 0

        switch object {
        case let .struct(structObject):
            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: structObject,
                allDeclarationObjects: allDeclarationObjects
            )

            var allAnnotatedDecl = [structObject.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            numberOfConformances = conformedProtocolObjects.count

            allAnnotatedDecl.append(contentsOf: structObject.initializers.map { $0.annotatedDecl })
            numberOfInitializers = structObject.initializers.count

            allAnnotatedDecl.append(contentsOf: structObject.variables.map { $0.annotatedDecl })
            numberOfVariables = structObject.variables.count

            allAnnotatedDecl.append(contentsOf: structObject.functions.map { $0.annotatedDecl })
            numberOfFunctions = structObject.functions.count

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            self.bodyWidth = bodyWidth
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

        case let .class(classObject):
            let superClassObject = extractSuperClassObject(
                by: classObject,
                allDeclarationObjects: allDeclarationObjects
            )

            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: classObject,
                allDeclarationObjects: allDeclarationObjects
            )
            numberOfConformances = conformedProtocolObjects.count

            var allAnnotatedDecl = [classObject.annotatedDecl]
            if let superClassObject {
                allAnnotatedDecl.append(superClassObject.annotatedDecl)
                hasSuperClass = true
            }
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            numberOfConformances = conformedProtocolObjects.count

            allAnnotatedDecl.append(contentsOf: classObject.initializers.map { $0.annotatedDecl })
            numberOfInitializers = classObject.initializers.count

            allAnnotatedDecl.append(contentsOf: classObject.variables.map { $0.annotatedDecl })
            numberOfVariables = classObject.variables.count

            allAnnotatedDecl.append(contentsOf: classObject.functions.map { $0.annotatedDecl })
            numberOfFunctions = classObject.functions.count

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            self.bodyWidth = bodyWidth
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

        case let .enum(enumObject):
            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: enumObject,
                allDeclarationObjects: allDeclarationObjects
            )
            numberOfConformances = conformedProtocolObjects.count

            var allAnnotatedDecl = [enumObject.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            numberOfConformances = conformedProtocolObjects.count

            allAnnotatedDecl.append(contentsOf: enumObject.cases.map { $0.annotatedDecl })
            numberOfCases = enumObject.cases.count

            allAnnotatedDecl.append(contentsOf: enumObject.variables.map { $0.annotatedDecl })
            numberOfVariables = enumObject.variables.count

            allAnnotatedDecl.append(contentsOf: enumObject.functions.map { $0.annotatedDecl })
            numberOfFunctions = enumObject.functions.count

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            self.bodyWidth = bodyWidth
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

        case let .protocol(protocolObject):
            let parentProtocolObjects = extractParentProtocolObjects(
                by: protocolObject,
                allDeclarationObjects: allDeclarationObjects
            )

            var allAnnotatedDecl = [protocolObject.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: parentProtocolObjects.map { $0.annotatedDecl })
            numberOfParentProtocols = parentProtocolObjects.count

            allAnnotatedDecl.append(contentsOf: protocolObject.initializers.map { $0.annotatedDecl })
            numberOfInitializers = protocolObject.initializers.count

            allAnnotatedDecl.append(contentsOf: protocolObject.variables.map { $0.annotatedDecl })
            numberOfVariables = protocolObject.variables.count

            allAnnotatedDecl.append(contentsOf: protocolObject.functions.map { $0.annotatedDecl })
            numberOfFunctions = protocolObject.functions.count

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            self.bodyWidth = bodyWidth
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

        case let .actor(actorObject):
            let conformedProtocolObjects = extractConformedProtocolObjects(
                by: actorObject,
                allDeclarationObjects: allDeclarationObjects
            )

            var allAnnotatedDecl = [actorObject.annotatedDecl]
            allAnnotatedDecl.append(contentsOf: conformedProtocolObjects.map { $0.annotatedDecl })
            numberOfConformances = conformedProtocolObjects.count

            allAnnotatedDecl.append(contentsOf: actorObject.initializers.map { $0.annotatedDecl })
            numberOfInitializers = actorObject.initializers.count

            allAnnotatedDecl.append(contentsOf: actorObject.variables.map { $0.annotatedDecl })
            numberOfVariables = actorObject.variables.count

            allAnnotatedDecl.append(contentsOf: actorObject.functions.map { $0.annotatedDecl })
            numberOfFunctions = actorObject.functions.count

            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            self.bodyWidth = bodyWidth
            frameWidth = bodyWidth
            + ComponentSizeValues.arrowTerminalWidth * 2
            + ComponentSizeValues.borderWidth
        }

        var frameHeight: CGFloat = itemHeight * 2 + bottomPadding
        if hasSuperClass {
            frameHeight += connectionHeight + itemHeight + bottomPadding
        }
        if numberOfParentProtocols > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfParentProtocols) + bottomPadding
        }
        if numberOfConformances > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfConformances) + bottomPadding
        }
        if numberOfInitializers > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfInitializers) + bottomPadding
        }
        if numberOfCases > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfCases) + bottomPadding
        }
        if numberOfVariables > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfVariables) + bottomPadding
        }
        if numberOfFunctions > 0 {
            frameHeight += connectionHeight + itemHeight * CGFloat(numberOfFunctions) + bottomPadding
        }
        frameHeight += connectionHeight + borderWidth

        self.frameHeight = frameHeight
    }
}
