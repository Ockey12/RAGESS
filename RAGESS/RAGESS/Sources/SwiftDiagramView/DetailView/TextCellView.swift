//
//  TextCellView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

struct TextCellView: View {
    let store: StoreOf<TextCellReducer>

    var body: some View {
        Text(store.object.annotatedDecl)
            .font(.system(size: ComponentSizeValues.fontSize))
            .foregroundStyle(.black)
            .padding(.leading, ComponentSizeValues.textLeadingPadding)
            .offset(x: ComponentSizeValues.arrowTerminalWidth)
            .frame(
                width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                height: ComponentSizeValues.itemHeight,
                alignment: .leading
            )
            .border(.red)
            .onTapGesture {
                store.send(.clicked)
            }
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

    return TextCellView(
        store: .init(
            initialState: TextCellReducer.State(
                object: protocolObject,
                topLeadingPoint: CGPoint(x: 0, y: 0),
                bodyWidth: 800
            ),
            reducer: { TextCellReducer() }
        )
    )
}
