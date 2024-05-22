//
//  HeaderViewWithoutIndex.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

struct HeaderViewWithoutIndex: View {
    let store: StoreOf<HeaderReducer>

    let borderWidth = ComponentSizeValues.borderWidth
    let fontSize = ComponentSizeValues.fontSize
    let itemHeight = ComponentSizeValues.itemHeight
    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let textLeadingPadding = ComponentSizeValues.textLeadingPadding

    var body: some View {
        ZStack {
            HeaderFrameWithoutIndex(bodyWidth: store.bodyWidth)
                .foregroundStyle(.white)

            HeaderFrameWithoutIndex(bodyWidth: store.bodyWidth)
                .stroke(lineWidth: borderWidth)
                .fill(.black)

            Text(store.object.annotatedDecl)
                .font(.system(size: fontSize))
                .foregroundStyle(.black)
                .frame(width: store.bodyWidth, height: 10, alignment: .leading)
                .position(x: (store.bodyWidth + textLeadingPadding) / 2 + arrowTerminalWidth, y: itemHeight / 2)
                .onTapGesture {
                    store.send(.nameClicked)
                }
        } // ZStack
        .frame(
            width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
            height: 210
        )
    }
}

#Preview {
    let protocolObject = ProtocolObject(
        name: "SampleProtocol",
        nameOffset: 0,
        fullPath: "",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    return Group {
        HeaderViewWithoutIndex(
            store: .init(
                initialState: HeaderReducer.State(
                    object: protocolObject,
                    bodyWidth: max(
                        protocolObject.name.systemSize50Width,
                        ComponentSizeValues.bodyMinWidth
                    )
                ),
                reducer: { HeaderReducer() }
            )
        )
    }
    .frame(width: 1000)
    .padding()
}
