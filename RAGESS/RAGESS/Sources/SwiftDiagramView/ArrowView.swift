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
//    let startPoint: CGPoint
//    let endPoint: CGPoint

    var body: some View {
        let path = Path { path in
            path.move(to: store.startPoint)
            path.addLine(to: store.endPoint)

            // Arrow tip
            let arrowSize: CGFloat = 15

            // first
            let firstTipPoint = CGPoint(
                x: store.startPoint.x + (store.endPoint.x - store.startPoint.x) / 3,
                y: store.startPoint.y + (store.endPoint.y - store.startPoint.y) / 3
            )

            let firstAngle = atan2(firstTipPoint.y - store.startPoint.y, firstTipPoint.x - store.startPoint.x)
            let firstTipPoint1 = CGPoint(
                x: firstTipPoint.x - arrowSize * cos(firstAngle - CGFloat.pi / 6),
                y: firstTipPoint.y - arrowSize * sin(firstAngle - CGFloat.pi / 6)
            )
            let firstTipPoint2 = CGPoint(
                x: firstTipPoint.x - arrowSize * cos(firstAngle + CGFloat.pi / 6),
                y: firstTipPoint.y - arrowSize * sin(firstAngle + CGFloat.pi / 6)
            )
            path.move(to: firstTipPoint)
            path.addLine(to: firstTipPoint1)
            path.move(to: firstTipPoint)
            path.addLine(to: firstTipPoint2)

            // second
            let secondTipPoint = CGPoint(
                x: store.startPoint.x + (store.endPoint.x - store.startPoint.x) * 2 / 3,
                y: store.startPoint.y + (store.endPoint.y - store.startPoint.y) * 2 / 3
            )

            let secondAngle = atan2(secondTipPoint.y - store.startPoint.y, secondTipPoint.x - store.startPoint.x)
            let secondTipPoint1 = CGPoint(
                x: secondTipPoint.x - arrowSize * cos(secondAngle - CGFloat.pi / 6),
                y: secondTipPoint.y - arrowSize * sin(secondAngle - CGFloat.pi / 6)
            )
            let secondTipPoint2 = CGPoint(
                x: secondTipPoint.x - arrowSize * cos(secondAngle + CGFloat.pi / 6),
                y: secondTipPoint.y - arrowSize * sin(secondAngle + CGFloat.pi / 6)
            )
            path.move(to: secondTipPoint)
            path.addLine(to: secondTipPoint1)
            path.move(to: secondTipPoint)
            path.addLine(to: secondTipPoint2)
        }

        path.stroke(Color("Arrow", bundle: .module), lineWidth: 3)
    }
}
