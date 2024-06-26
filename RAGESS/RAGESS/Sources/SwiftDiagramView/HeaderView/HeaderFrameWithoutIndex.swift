//
//  HeaderFrameWithoutIndex.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import SwiftUI

struct HeaderFrameWithoutIndex: Shape {
    var frameWidth: CGFloat
    var widthFromLeftEdgeToConnection: CGFloat {
        (frameWidth - connectionWidth) / 2 + arrowTerminalWidth
    }

    let connectionWidth = ComponentSizeValues.connectionWidth
    let connectionHeight = ComponentSizeValues.connectionHeight
    let oneVerticalLineWithoutArrow = ComponentSizeValues.oneVerticalLineWithoutArrow
    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let arrowTerminalHeight = ComponentSizeValues.arrowTerminalHeight
    let bottomPaddingForLastText = ComponentSizeValues.bottomPaddingForLastText

    func path(in rect: CGRect) -> Path {
        Path { path in
            // left side
            // from top to bottom
            path.move(to: CGPoint(x: arrowTerminalWidth, y: 0))
            path.addLine(to: CGPoint(x: arrowTerminalWidth, y: oneVerticalLineWithoutArrow))
            path.addLine(to: CGPoint(x: 0, y: oneVerticalLineWithoutArrow))
            path.addLine(to: CGPoint(x: 0, y: oneVerticalLineWithoutArrow + arrowTerminalHeight))
            path.addLine(to: CGPoint(x: arrowTerminalWidth, y: oneVerticalLineWithoutArrow + arrowTerminalHeight))
            path.addLine(to: CGPoint(x: arrowTerminalWidth, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText + connectionHeight))

            // bottom
            // from left to right
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText + connectionHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText + connectionHeight))
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth, y: oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight + bottomPaddingForLastText + connectionHeight))

            // right side
            // from bottom to top
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth, y: oneVerticalLineWithoutArrow + arrowTerminalHeight))
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth * 2, y: oneVerticalLineWithoutArrow + arrowTerminalHeight))
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth * 2, y: oneVerticalLineWithoutArrow))
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth, y: oneVerticalLineWithoutArrow))
            path.addLine(to: CGPoint(x: frameWidth + arrowTerminalWidth, y: 0))
            path.closeSubpath()
        } // Path
    } // func path(in rect: CGRect) -> Path
}

#Preview {
    VStack {
        HeaderFrameWithoutIndex(frameWidth: ComponentSizeValues.bodyMinWidth)
            .stroke(lineWidth: ComponentSizeValues.borderWidth)
    }
    .frame(width: ComponentSizeValues.bodyMinWidth + 100)
    .padding()
}
