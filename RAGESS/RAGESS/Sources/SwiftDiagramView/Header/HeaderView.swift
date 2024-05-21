//
//  HeaderView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import SwiftUI
import TypeDeclaration

struct HeaderView: View {
    let object: any HasHeader
    let bodyWidth: CGFloat

    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let itemHeight = ComponentSizeValues.itemHeight

    var body: some View {
        ZStack(alignment: .topLeading) {
            IndexView(object: object)
                .offset(x: arrowTerminalWidth, y: 0)

            HeaderViewWithoutIndex(object: object, bodyWidth: bodyWidth)
                .offset(x: 0, y: itemHeight)
        } // ZStack
    }
}

#Preview {
    Group {
        HeaderView(
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
        .frame(width: 1000, height: 300)
        .padding()

        HeaderView(
            object: StructObject(
                name: "SampleStruct",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            ),
            bodyWidth: max(
                "SampleStruct".systemSize50Width,
                ComponentSizeValues.bodyMinWidth
            )
        )
        .frame(width: 1000, height: 300)
        .padding()

        HeaderView(
            object: ClassObject(
                name: "SampleClass",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            ),
            bodyWidth: max(
                "SampleClass".systemSize50Width,
                ComponentSizeValues.bodyMinWidth
            )
        )
        .frame(width: 1000, height: 300)
        .padding()

        HeaderView(
            object: EnumObject(
                name: "SampleEnum",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            ),
            bodyWidth: max(
                "SampleEnum".systemSize50Width,
                ComponentSizeValues.bodyMinWidth
            )
        )
        .frame(width: 1000, height: 300)
        .padding()
    }
}
