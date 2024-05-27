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
            let arrowSize: CGFloat = 30
            let angle = atan2(store.endPoint.y - store.startPoint.y, store.endPoint.x - store.startPoint.x)
            let arrowPoint1 = CGPoint(
                x: store.endPoint.x - arrowSize * cos(angle - CGFloat.pi / 6),
                y: store.endPoint.y - arrowSize * sin(angle - CGFloat.pi / 6)
            )
            let arrowPoint2 = CGPoint(
                x: store.endPoint.x - arrowSize * cos(
                    angle + CGFloat.pi / 6
                ),
                y: store.endPoint.y - arrowSize * sin(angle + CGFloat.pi / 6)
            )

            path.addLine(to: arrowPoint1)
            path.move(to: store.endPoint)
            path.addLine(to: arrowPoint2)
        }

        path.stroke(Color.black, lineWidth: 10)
    }
}
