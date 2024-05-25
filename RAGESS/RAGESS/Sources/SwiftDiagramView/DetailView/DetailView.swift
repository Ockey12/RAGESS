//
//  DetailView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

struct DetailView: View {
    let store: StoreOf<DetailReducer>

    var body: some View {
        ZStack(alignment: .topLeading) {
            DetailFrameShape(
                frameWidth: store.frameWidth,
                numberOfItems: store.texts.count
            )
            .foregroundStyle(.white)

            DetailFrameShape(
                frameWidth: store.frameWidth,
                numberOfItems: store.texts.count
            )
            .stroke(lineWidth: ComponentSizeValues.borderWidth)
            .fill(.black)

            Text(store.kind.text)
                .font(.system(size: ComponentSizeValues.fontSize))
                .frame(
                    width: store.frameWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                    height: ComponentSizeValues.itemHeight
                )

            VStack(alignment: .leading, spacing: 0) {
                ForEach(store.scope(state: \.texts, action: \.texts)) { textCellStore in
                    TextCellView(store: textCellStore)
                }
            } // VStack
            .padding(.top, ComponentSizeValues.itemHeight)
        } // ZStack
        .frame(
            width: store.frameWidth + ComponentSizeValues.arrowTerminalWidth * 2,
            height: store.height
        )
        .border(.orange)
    }
}

#Preview {
    let functionObjects = [
        FunctionObject(
            name: "Function1",
            nameOffset: 0,
            fullPath: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        FunctionObject(
            name: "Function2",
            nameOffset: 0,
            fullPath: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        ),
        FunctionObject(
            name: "Function3",
            nameOffset: 0,
            fullPath: "",
            positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
            offsetRange: 0 ... 1
        )
    ]

    return VStack {
        DetailView(
            store: .init(
                initialState: DetailReducer.State(
                    objects: functionObjects,
                    kind: .functions,
                    topLeadingPoint: CGPoint(x: 0, y: 0),
                    frameWidth: 800
                ),
                reducer: { DetailReducer() }
            )
        )
        .border(.pink)
        .padding()
    }
    .frame(width: 900, height: 800)
}
