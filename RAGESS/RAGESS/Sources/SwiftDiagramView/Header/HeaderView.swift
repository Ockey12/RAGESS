//
//  HeaderView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

struct HeaderView: View {
    let store: StoreOf<HeaderReducer>

    let arrowTerminalWidth = ComponentSizeValues.arrowTerminalWidth
    let itemHeight = ComponentSizeValues.itemHeight

    var body: some View {
        ZStack(alignment: .topLeading) {
            IndexView(object: store.object)
                .offset(x: arrowTerminalWidth, y: 0)

            HeaderViewWithoutIndex(object: store.object, bodyWidth: store.bodyWidth)
                .offset(x: 0, y: itemHeight)
        } // ZStack
        .frame(
            width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth*2,
            height: 300
        )
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

    let structObject = StructObject(
        name: "SampleStruct",
        nameOffset: 0,
        fullPath: "",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let classObject = ClassObject(
        name: "SampleClass",
        nameOffset: 0,
        fullPath: "",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let enumObject = EnumObject(
        name: "SampleEnum",
        nameOffset: 0,
        fullPath: "",
        sourceCode: "",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    return Group {
        HeaderView(
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
        .border(.pink)

        HeaderView(
            store: .init(
                initialState: HeaderReducer.State(
                    object: structObject,
                    bodyWidth: max(
                        structObject.name.systemSize50Width,
                        ComponentSizeValues.bodyMinWidth
                    )
                ),
                reducer: { HeaderReducer() }
            )
        )
        .border(.pink)

        HeaderView(
            store: .init(
                initialState: HeaderReducer.State(
                    object: classObject,
                    bodyWidth: max(
                        classObject.name.systemSize50Width,
                        ComponentSizeValues.bodyMinWidth
                    )
                ),
                reducer: { HeaderReducer() }
            )
        )
        .border(.pink)

        HeaderView(
            store: .init(
                initialState: HeaderReducer.State(
                    object: enumObject,
                    bodyWidth: max(
                        enumObject.name.systemSize50Width,
                        ComponentSizeValues.bodyMinWidth
                    )
                ),
                reducer: { HeaderReducer() }
            )
        )
        .border(.pink)
    }
    .frame(width: 1000, height: 400)
}
