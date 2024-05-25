//
//  ArrowView.swift
//
//
//  Created by Ockey12 on 2024/05/25
//
//

import SwiftUI

struct ArrowView: View {
    let startPoint: CGPoint
    let endPoint: CGPoint

    var body: some View {
        GeometryReader { _ in
            let path = Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)

                // Arrow tip
                let arrowSize: CGFloat = 10
                let angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
                let arrowPoint1 = CGPoint(
                    x: endPoint.x - arrowSize * cos(angle - CGFloat.pi / 6),
                    y: endPoint.y - arrowSize * sin(angle - CGFloat.pi / 6)
                )
                let arrowPoint2 = CGPoint(
                    x: endPoint.x - arrowSize * cos(
                        angle + CGFloat.pi / 6
                    ),
                    y: endPoint.y - arrowSize * sin(angle + CGFloat.pi / 6)
                )

                path.addLine(to: arrowPoint1)
                path.move(to: endPoint)
                path.addLine(to: arrowPoint2)
            }

            path.stroke(Color.black, lineWidth: 4)
        }
    }
}
