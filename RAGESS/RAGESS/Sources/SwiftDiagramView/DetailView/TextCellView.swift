//
//  TextCellView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI

struct TextCellView: View {
    let store: StoreOf<TextCellReducer>
    @State private var onHover = false

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: ComponentSizeValues.arrowTerminalWidth, height: ComponentSizeValues.arrowTerminalHeight)
                .padding(.vertical, ComponentSizeValues.oneVerticalLineWithoutArrow)
                .foregroundStyle(onHover ? Color("SelectedCell", bundle: .module) : .clear)

            Text(store.object.declaration)
                .font(.system(size: ComponentSizeValues.fontSize))
                .foregroundStyle(Color("TextCellFont", bundle: .module))
                .padding(.leading, ComponentSizeValues.textLeadingPadding)
                .frame(width: store.bodyWidth, alignment: .leading)
                .background(onHover ? Color("SelectedCell", bundle: .module) : .clear)
#if DEBUG
                .border(.red)
#endif
                .onTapGesture {
                    store.send(.clicked)
                }

            Rectangle()
                .frame(width: ComponentSizeValues.arrowTerminalWidth, height: ComponentSizeValues.arrowTerminalHeight)
                .padding(.vertical, ComponentSizeValues.oneVerticalLineWithoutArrow)
                .foregroundStyle(onHover ? Color("SelectedCell", bundle: .module) : .clear)
        }
        .onHover { onHover in
            self.onHover = onHover
        }
    }
}

//
// #Preview {
//    let protocolObject = ProtocolObject(
//        name: "SampleProtocol",
//        nameOffset: 0,
//        fullPath: "",
//        sourceCode: "",
//        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//        offsetRange: 0 ... 1
//    )
//
//    return TextCellView(
//        store: .init(
//            initialState: TextCellReducer.State(
//                object: protocolObject,
//                topLeadingPoint: CGPoint(x: 0, y: 0),
//                bodyWidth: 800
//            ),
//            reducer: { TextCellReducer() }
//        )
//    )
// }
