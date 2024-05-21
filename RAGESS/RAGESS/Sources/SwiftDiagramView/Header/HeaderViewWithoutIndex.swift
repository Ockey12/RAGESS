//
//  HeaderViewWithoutIndex.swift
//  
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import SwiftUI
import TypeDeclaration

struct HeaderViewWithoutIndex: View {
    let object: any HasHeader
    let bodyWidth: CGFloat

    let borderWidth = ComponentSizeValues.borderWidth
    let fontSize = ComponentSizeValues.fontSize
    let itemHeight = ComponentSizeValues.itemHeight
    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let textLeadingPadding = ComponentSizeValues.textLeadingPadding

    var body: some View {
        ZStack {
            HeaderFrameWithoutIndex(bodyWidth: bodyWidth)
                .foregroundStyle(.white)

            HeaderFrameWithoutIndex(bodyWidth: bodyWidth)
                .stroke(lineWidth: borderWidth)
                .fill(.black)

            Text(object.annotatedDecl)
                .font(.system(size: fontSize))
                .foregroundStyle(.black)
                .frame(width: bodyWidth, alignment: .leading)
                .position(x: (bodyWidth + textLeadingPadding)/2 + arrowTerminalWidth, y: itemHeight/2)
        } // ZStack
    }
}

#Preview {
    HeaderViewWithoutIndex(
        object: ProtocolObject(
            name: "SampleProtocol",
            nameOffset: 0,
            fullPath: "",
            sourceCode: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        bodyWidth: max(
            "SampleProtocol".systemSize50Width,
            ComponentSizeValues.bodyMinWidth
        )
    )
    .frame(width: 1000)
    .padding()
}
