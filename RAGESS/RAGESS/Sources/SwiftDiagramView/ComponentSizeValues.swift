//
//  ComponentSizeValues.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import Foundation

enum ComponentSizeValues {
    static let bodyMinWidth: CGFloat = 800 / 4

    static let fontSize: CGFloat = 50 / 4
    static let itemHeight: CGFloat = 90 / 4
    static let borderWidth: CGFloat = 5 / 4

    static let connectionWidth: CGFloat = 400 / 4
    static let connectionHeight: CGFloat = 90 / 4

    static let arrowTerminalWidth: CGFloat = 15 / 4
    static let arrowTerminalHeight: CGFloat = 30 / 4
    static var oneVerticalLineWithoutArrow: CGFloat {
        (itemHeight - arrowTerminalHeight) / 2
    }

    static let bottomPaddingForLastText: CGFloat = 30 / 4
    static let textLeadingPadding: CGFloat = 30 / 4

    static let headerIndexWidth: CGFloat = 300 / 4

    static let typeRowsSpacing: CGFloat = 100 / 4

    static let verticalPaddingBetweenCombinedDiagrams: CGFloat = 500 / 4
    static let horizontalPaddingBetweenCombinedDiagrams: CGFloat = 1000 / 4

    static let PaddingAroundSwiftDiagramTreeView: CGFloat = 150
}
