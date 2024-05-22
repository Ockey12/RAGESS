//
//  DetailFrameShape.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import SwiftUI

struct DetailFrameShape: Shape {
    let bodyWidth: CGFloat
    var numberOfItems: Int

    var widthFromLeftEdgeToConnection: CGFloat {
        (bodyWidth - headerWidth) / 2 + arrowTerminalWidth
    }

    let headerWidth = ComponentSizeValues.connectionWidth
    let headerHeight = ComponentSizeValues.connectionHeight
    let itemHeight = ComponentSizeValues.itemHeight
    let oneVerticalLineWithoutArrow = ComponentSizeValues.oneVerticalLineWithoutArrow
    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let arrowTerminalHeight = ComponentSizeValues.arrowTerminalHeight
    let bottomPaddingForLastText = ComponentSizeValues.bottomPaddingForLastText

    func path(in rect: CGRect) -> Path {
        Path { path in
            // header
            // from right to left
            path.move(to: CGPoint(x: arrowTerminalWidth + bodyWidth, y: headerHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + headerWidth, y: headerHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + headerWidth, y: 0))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: 0))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: headerHeight))
            path.addLine(to: CGPoint(x: arrowTerminalWidth, y: headerHeight))

            // items
            // left side
            // from top to bottom
            for numberOfItem in 0 ..< numberOfItems {
                path.addLine(to: CGPoint(x: arrowTerminalWidth, y: headerHeight + itemHeight * CGFloat(numberOfItem) + oneVerticalLineWithoutArrow))
                path.addLine(to: CGPoint(x: 0, y: headerHeight + itemHeight * CGFloat(numberOfItem) + oneVerticalLineWithoutArrow))
                path.addLine(to: CGPoint(x: 0, y: headerHeight + itemHeight * CGFloat(numberOfItem) + oneVerticalLineWithoutArrow + arrowTerminalHeight))
                path.addLine(to: CGPoint(x: arrowTerminalWidth, y: headerHeight + itemHeight * CGFloat(numberOfItem) + oneVerticalLineWithoutArrow + arrowTerminalHeight))
                path.addLine(to: CGPoint(x: arrowTerminalWidth, y: headerHeight + itemHeight * CGFloat(numberOfItem) + oneVerticalLineWithoutArrow * 2 + arrowTerminalHeight))
            }

            // footer
            // from left to right
            path.addLine(to: CGPoint(x: arrowTerminalWidth, y: bottomPaddingForLastText + headerHeight * 2 + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: bottomPaddingForLastText + headerHeight * 2 + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: bottomPaddingForLastText + headerHeight + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + headerWidth, y: bottomPaddingForLastText + headerHeight + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + headerWidth, y: bottomPaddingForLastText + headerHeight * 2 + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: bodyWidth + arrowTerminalWidth, y: bottomPaddingForLastText + headerHeight * 2 + itemHeight * CGFloat(numberOfItems)))
            path.addLine(to: CGPoint(x: bodyWidth + arrowTerminalWidth, y: headerHeight + itemHeight * CGFloat(numberOfItems)))

            // items
            // right side
            // from bottom to top
            for numberOfItem in 0 ..< numberOfItems {
                let numberOfItemFromBottom = numberOfItems - (numberOfItem + 1)
                path.addLine(to: CGPoint(x: arrowTerminalWidth + bodyWidth, y: headerHeight + itemHeight * CGFloat(numberOfItemFromBottom) + oneVerticalLineWithoutArrow + arrowTerminalHeight))
                path.addLine(to: CGPoint(x: arrowTerminalWidth * 2 + bodyWidth, y: headerHeight + itemHeight * CGFloat(numberOfItemFromBottom) + oneVerticalLineWithoutArrow + arrowTerminalHeight))
                path.addLine(to: CGPoint(x: arrowTerminalWidth * 2 + bodyWidth, y: headerHeight + itemHeight * CGFloat(numberOfItemFromBottom) + oneVerticalLineWithoutArrow))
                path.addLine(to: CGPoint(x: arrowTerminalWidth + bodyWidth, y: headerHeight + itemHeight * CGFloat(numberOfItemFromBottom) + oneVerticalLineWithoutArrow))
                path.addLine(to: CGPoint(x: arrowTerminalWidth + bodyWidth, y: headerHeight + itemHeight * CGFloat(numberOfItemFromBottom)))
            }
        } // Path
    } // func path(in rect: CGRect) -> Path
}

#Preview {
    VStack {
        DetailFrameShape(
            bodyWidth: ComponentSizeValues.bodyMinWidth,
            numberOfItems: 1
        )
        .stroke(lineWidth: ComponentSizeValues.borderWidth)
        .border(.pink)
        .padding()

        DetailFrameShape(
            bodyWidth: ComponentSizeValues.bodyMinWidth,
            numberOfItems: 5
        )
        .stroke(lineWidth: ComponentSizeValues.borderWidth)
        .border(.pink)
        .padding()
    }
    .frame(width: 900, height: 1500)
}
