//
//  ArrowView.swift
//
//
//  Created by Ockey12 on 2024/05/25
//
//

import ComposableArchitecture
import SwiftUI

struct ArrowView: View {
    let store: StoreOf<ArrowViewReducer>
    private let arrowSize: CGFloat = 15

    var body: some View {
        let path = Path { path in
            if store.startPoint.x == store.endPoint.x {
                let maxWidth = ComponentSizeValues.horizontalPaddingBetweenCombinedDiagrams * 0.45
                let minWidth = ComponentSizeValues.horizontalPaddingBetweenCombinedDiagrams * 0.1
                var width = CGFloat.random(in: minWidth ... maxWidth)
                if store.startPointSide == .leading {
                    width *= -1
                }

                if store.startPoint.y == store.endPoint.y {
                    // triangle
                    let positiveCorner = CGPoint(
                        x: store.startPoint.x + width,
                        y: store.startPoint.y + ComponentSizeValues.itemHeight * 2 / 3
                    )
                    let negativeCorner = CGPoint(
                        x: store.startPoint.x + width,
                        y: store.startPoint.y - ComponentSizeValues.itemHeight * 2 / 3
                    )
                    path.move(to: store.startPoint)
                    path.addLine(to: positiveCorner)
                    path.addLine(to: negativeCorner)
                    path.addLine(to: store.startPoint)

                    let tipPoint = CGPoint(
                        x: positiveCorner.x,
                        y: store.startPoint.y + 7
                    )
//                    let tipAngle = atan2(negativeCorner.y - positiveCorner.y, negativeCorner.x - positiveCorner.x)
                    let tipAngle = atan2(positiveCorner.y - negativeCorner.y, positiveCorner.x - negativeCorner.x)
                    let tipNegativePoint = CGPoint(
                        x: tipPoint.x - arrowSize * cos(tipAngle - CGFloat.pi / 6),
                        y: tipPoint.y - arrowSize * sin(tipAngle - CGFloat.pi / 6)
                    )
                    let tipPositivePoint = CGPoint(
                        x: tipPoint.x - arrowSize * cos(tipAngle + CGFloat.pi / 6),
                        y: tipPoint.y - arrowSize * sin(tipAngle + CGFloat.pi / 6)
                    )
                    path.move(to: tipPoint)
                    path.addLine(to: tipNegativePoint)
                    path.move(to: tipPoint)
                    path.addLine(to: tipPositivePoint)
                } else {
                    // curve
                    let firstCorner = CGPoint(
                        x: store.startPoint.x + width,
                        y: store.startPoint.y + (store.endPoint.y - store.startPoint.y) / 3
                    )

                    let secondCorner = CGPoint(
                        x: firstCorner.x,
                        y: firstCorner.y + (store.endPoint.y - store.startPoint.y) / 3
                    )

                    path.move(to: store.startPoint)
                    path.addLine(to: firstCorner)
                    path.addLine(to: secondCorner)
                    path.addLine(to: store.endPoint)

                    // Arrow tip
                    // first
                    let firstTipPoint = CGPoint(
                        x: store.startPoint.x + (firstCorner.x - store.startPoint.x) / 2,
                        y: store.startPoint.y + (firstCorner.y - store.startPoint.y) / 2
                    )
                    let firstTipAngle = atan2(firstCorner.y - store.startPoint.y, firstCorner.x - store.startPoint.x)
                    let firstTipNegativePoint = CGPoint(
                        x: firstTipPoint.x - arrowSize * cos(firstTipAngle - CGFloat.pi / 6),
                        y: firstTipPoint.y - arrowSize * sin(firstTipAngle - CGFloat.pi / 6)
                    )
                    let firstTipPositivePoint = CGPoint(
                        x: firstTipPoint.x - arrowSize * cos(firstTipAngle + CGFloat.pi / 6),
                        y: firstTipPoint.y - arrowSize * sin(firstTipAngle + CGFloat.pi / 6)
                    )
                    path.move(to: firstTipPoint)
                    path.addLine(to: firstTipNegativePoint)
                    path.move(to: firstTipPoint)
                    path.addLine(to: firstTipPositivePoint)

                    if fabs(Double(firstCorner.y) - Double(secondCorner.y)) > Double(ComponentSizeValues.itemHeight) * 3 {
                        // second
                        // vertical segment
                        let secondTipPoint = CGPoint(
                            x: firstCorner.x + (secondCorner.x - firstCorner.x) / 2,
                            y: firstCorner.y + (secondCorner.y - firstCorner.y) / 2
                        )
                        let secondTipAngle = atan2(secondCorner.y - firstCorner.y, secondCorner.x - firstCorner.x)
                        let secondTipNegativePoint = CGPoint(
                            x: secondTipPoint.x - arrowSize * cos(secondTipAngle - CGFloat.pi / 6),
                            y: secondTipPoint.y - arrowSize * sin(secondTipAngle - CGFloat.pi / 6)
                        )
                        let secondTipPositivePoint = CGPoint(
                            x: secondTipPoint.x - arrowSize * cos(secondTipAngle + CGFloat.pi / 6),
                            y: secondTipPoint.y - arrowSize * sin(secondTipAngle + CGFloat.pi / 6)
                        )
                        path.move(to: secondTipPoint)
                        path.addLine(to: secondTipNegativePoint)
                        path.move(to: secondTipPoint)
                        path.addLine(to: secondTipPositivePoint)
                    }

                    // third
                    let thirdTipPoint = CGPoint(
                        x: secondCorner.x + (store.endPoint.x - secondCorner.x) / 2,
                        y: secondCorner.y + (store.endPoint.y - secondCorner.y) / 2
                    )
                    let thirdTipAngle = atan2(store.endPoint.y - secondCorner.y, store.endPoint.x - secondCorner.x)
                    let thirdTipNegativePoint = CGPoint(
                        x: thirdTipPoint.x - arrowSize * cos(thirdTipAngle - CGFloat.pi / 6),
                        y: thirdTipPoint.y - arrowSize * sin(thirdTipAngle - CGFloat.pi / 6)
                    )
                    let thirdTipPositivePoint = CGPoint(
                        x: thirdTipPoint.x - arrowSize * cos(thirdTipAngle + CGFloat.pi / 6),
                        y: thirdTipPoint.y - arrowSize * sin(thirdTipAngle + CGFloat.pi / 6)
                    )
                    path.move(to: thirdTipPoint)
                    path.addLine(to: thirdTipNegativePoint)
                    path.move(to: thirdTipPoint)
                    path.addLine(to: thirdTipPositivePoint)
                }
            } else {
                // straight line segment
                path.move(to: store.startPoint)
                path.addLine(to: store.endPoint)

                // Arrow tip
                // first
                let firstTipPoint = CGPoint(
                    x: store.startPoint.x + (store.endPoint.x - store.startPoint.x) / 3,
                    y: store.startPoint.y + (store.endPoint.y - store.startPoint.y) / 3
                )
                let firstAngle = atan2(firstTipPoint.y - store.startPoint.y, firstTipPoint.x - store.startPoint.x)
                let firstTipNegativePoint = CGPoint(
                    x: firstTipPoint.x - arrowSize * cos(firstAngle - CGFloat.pi / 6),
                    y: firstTipPoint.y - arrowSize * sin(firstAngle - CGFloat.pi / 6)
                )
                let firstTipPositivePoint = CGPoint(
                    x: firstTipPoint.x - arrowSize * cos(firstAngle + CGFloat.pi / 6),
                    y: firstTipPoint.y - arrowSize * sin(firstAngle + CGFloat.pi / 6)
                )
                path.move(to: firstTipPoint)
                path.addLine(to: firstTipNegativePoint)
                path.move(to: firstTipPoint)
                path.addLine(to: firstTipPositivePoint)

                // second
                let secondTipPoint = CGPoint(
                    x: store.startPoint.x + (store.endPoint.x - store.startPoint.x) * 2 / 3,
                    y: store.startPoint.y + (store.endPoint.y - store.startPoint.y) * 2 / 3
                )
                let secondAngle = atan2(secondTipPoint.y - store.startPoint.y, secondTipPoint.x - store.startPoint.x)
                let secondTipNegativePoint = CGPoint(
                    x: secondTipPoint.x - arrowSize * cos(secondAngle - CGFloat.pi / 6),
                    y: secondTipPoint.y - arrowSize * sin(secondAngle - CGFloat.pi / 6)
                )
                let secondTipPositivePoint = CGPoint(
                    x: secondTipPoint.x - arrowSize * cos(secondAngle + CGFloat.pi / 6),
                    y: secondTipPoint.y - arrowSize * sin(secondAngle + CGFloat.pi / 6)
                )
                path.move(to: secondTipPoint)
                path.addLine(to: secondTipNegativePoint)
                path.move(to: secondTipPoint)
                path.addLine(to: secondTipPositivePoint)
            }
        }

        path.stroke(Color("Arrow", bundle: .module), lineWidth: 3)
    }
}
