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
    let kind: Kind

    var body: some View {
        ZStack(alignment: .topLeading) {
            DetailFrameShape(
                bodyWidth: store.bodyWidth,
                numberOfItems: store.items.count
            )
            .foregroundStyle(.white)

            DetailFrameShape(
                bodyWidth: store.bodyWidth,
                numberOfItems: store.items.count
            )
            .stroke(lineWidth: ComponentSizeValues.borderWidth)
            .fill(.black)

            Text(kind.text)
                .font(.system(size: ComponentSizeValues.fontSize))
                .frame(
                    width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                    height: ComponentSizeValues.itemHeight
                )

            VStack(alignment: .leading, spacing: 0) {
                ForEach(store.scope(state: \.items, action: \.items)) { textCellStore in
                    TextCellView(store: textCellStore)
                }
            } // VStack
            .padding(.top, ComponentSizeValues.itemHeight)
        } // ZStack
    }

    enum Kind {
        case initializers
        case variables
        case functions
        case `case`
        case nestType

        var text: String {
            switch self {
            case .initializers:
                "Initializer"
            case .variables:
                "Variables"
            case .functions:
                "Functions"
            case .case:
                "Case"
            case .nestType:
                "Nest"
            }
        }
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
                    bodyWidth: 800
                ),
                reducer: { DetailReducer() }
            ),
            kind: .functions
        )
        .padding()
    }
    .frame(width: 900, height: 800)
}
