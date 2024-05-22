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
        VStack(alignment: .leading, spacing: 0) {
            IndexView(object: store.object)
                .padding(.leading, arrowTerminalWidth)

            HeaderViewWithoutIndex(store: store)
        }
        .frame(
            width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
            height: 300
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

    return VStack(spacing: 50) {
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
    .frame(width: 1000, height: 1600)
    .padding()
}
