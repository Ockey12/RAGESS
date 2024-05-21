//
//  ComponentSizeValues.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import Foundation

enum ComponentSizeValues {
    static let bodyMinWidth: CGFloat = 800

    static let fontSize: CGFloat = 50
    static let itemHeight: CGFloat = 90
    static let borderWidth: CGFloat = 5

    static let connectionWidth: CGFloat = 400
    static let connectionHeight: CGFloat = 90

    static let arrowTerminalWidth: CGFloat = 15
    static let arrowTerminalHeight: CGFloat = 30
    static var oneVerticalLineWithoutArrow: CGFloat {
        (itemHeight - arrowTerminalHeight) / 2
    }

    static let bottomPaddingForLastText: CGFloat = 30
    static let textLeadingPadding: CGFloat = 30

    static let headerIndexWidth: CGFloat = 300
}
