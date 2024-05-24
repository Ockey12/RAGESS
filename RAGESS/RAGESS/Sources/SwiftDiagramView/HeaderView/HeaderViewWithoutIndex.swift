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
        ZStack(alignment: .topLeading) {
            HeaderFrameWithoutIndex(frameWidth: store.frameWidth)
                .foregroundStyle(.white)

            HeaderFrameWithoutIndex(frameWidth: store.frameWidth)
                .stroke(lineWidth: borderWidth)
                .fill(.black)

            Text(store.object.annotatedDecl)
                .font(.system(size: ComponentSizeValues.fontSize))
                .foregroundStyle(.black)
                .padding(.leading, ComponentSizeValues.textLeadingPadding)
                .offset(x: ComponentSizeValues.arrowTerminalWidth)
                .frame(
                    width: store.frameWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                    height: ComponentSizeValues.itemHeight,
                    alignment: .leading
                )
                .border(.blue)
                .onTapGesture {
                    store.send(.nameClicked)
                }
        } // ZStack
        .frame(
            width: store.frameWidth + ComponentSizeValues.arrowTerminalWidth * 2,
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
                    frameWidth: max(
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
