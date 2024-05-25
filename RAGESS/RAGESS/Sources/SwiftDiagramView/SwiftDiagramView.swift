//
//  SwiftDiagramView.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct SwiftDiagramView: View {
    let store: StoreOf<SwiftDiagramReducer>

    public init(store: StoreOf<SwiftDiagramReducer>) {
        self.store = store
    }

    let spacing = ComponentSizeValues.typeRowsSpacing

    public var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: spacing) {
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(store.scope(state: \.protocols, action: \.protocols)) { protocolStore in
                        ProtocolView(store: protocolStore)
                            .border(.gray)
                    }
                }

                HStack(alignment: .top, spacing: spacing) {
                    ForEach(store.scope(state: \.structs, action: \.structs)) { structStore in
                        StructView(store: structStore)
                            .border(.green)
                    }
                }

                HStack(alignment: .top, spacing: spacing) {
                    ForEach(store.scope(state: \.classes, action: \.classes)) { classStore in
                        ClassView(store: classStore)
                            .border(.orange)
                    }
                }

                HStack(alignment: .top, spacing: spacing) {
                    ForEach(store.scope(state: \.enums, action: \.enums)) { enumStore in
                        EnumView(store: enumStore)
                            .border(.blue)
                    }
                }
            } // VStack
            .background {
                GeometryReader { geometry in
                    Path { _ in
                        store.send(.geometry(width: geometry.size.width, height: geometry.size.height))
                    }
                }
            }

            ForEach(store.protocols.elements) { state in
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 10, height: 10)
                    .position(x: state.topLeadingPoint.x, y: state.topLeadingPoint.y)

                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.leadingArrowTerminalPoint.x,
                        y: state.header.leadingArrowTerminalPoint.y
                    )

                Circle()
                    .foregroundStyle(.blue)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.trailingArrowTerminalPoint.x,
                        y: state.header.trailingArrowTerminalPoint.y
                    )
            }

            ForEach(store.structs.elements) { state in
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 10, height: 10)
                    .position(x: state.topLeadingPoint.x, y: state.topLeadingPoint.y)

                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.leadingArrowTerminalPoint.x,
                        y: state.header.leadingArrowTerminalPoint.y
                    )

                Circle()
                    .foregroundStyle(.blue)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.trailingArrowTerminalPoint.x,
                        y: state.header.trailingArrowTerminalPoint.y
                    )

                ForEach(state.details) { detail in
                    Circle()
                        .foregroundStyle(.orange)
                        .frame(width: 10, height: 10)
                        .position(
                            x: detail.topLeadingPoint.x,
                            y: detail.topLeadingPoint.y
                        )

                    ForEach(detail.texts) { text in
                        Circle()
                            .foregroundStyle(.red)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.leadingArrowTerminalPoint.x,
                                y: text.leadingArrowTerminalPoint.y
                            )

                        Circle()
                            .foregroundStyle(.blue)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.trailingArrowTerminalPoint.x,
                                y: text.trailingArrowTerminalPoint.y
                            )
                    }
                }
            }

            ForEach(store.classes.elements) { state in
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 10, height: 10)
                    .position(x: state.topLeadingPoint.x, y: state.topLeadingPoint.y)

                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.leadingArrowTerminalPoint.x,
                        y: state.header.leadingArrowTerminalPoint.y
                    )

                Circle()
                    .foregroundStyle(.blue)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.trailingArrowTerminalPoint.x,
                        y: state.header.trailingArrowTerminalPoint.y
                    )

                ForEach(state.details) { detail in
                    Circle()
                        .foregroundStyle(.orange)
                        .frame(width: 10, height: 10)
                        .position(
                            x: detail.topLeadingPoint.x,
                            y: detail.topLeadingPoint.y
                        )

                    ForEach(detail.texts) { text in
                        Circle()
                            .foregroundStyle(.red)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.leadingArrowTerminalPoint.x,
                                y: text.leadingArrowTerminalPoint.y
                            )

                        Circle()
                            .foregroundStyle(.blue)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.trailingArrowTerminalPoint.x,
                                y: text.trailingArrowTerminalPoint.y
                            )
                    }
                }
            }

            ForEach(store.enums.elements) { state in
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 10, height: 10)
                    .position(x: state.topLeadingPoint.x, y: state.topLeadingPoint.y)

                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.leadingArrowTerminalPoint.x,
                        y: state.header.leadingArrowTerminalPoint.y
                    )

                Circle()
                    .foregroundStyle(.blue)
                    .frame(width: 10, height: 10)
                    .position(
                        x: state.header.trailingArrowTerminalPoint.x,
                        y: state.header.trailingArrowTerminalPoint.y
                    )

                ForEach(state.details) { detail in
                    Circle()
                        .foregroundStyle(.orange)
                        .frame(width: 10, height: 10)
                        .position(
                            x: detail.topLeadingPoint.x,
                            y: detail.topLeadingPoint.y
                        )

                    ForEach(detail.texts) { text in
                        Circle()
                            .foregroundStyle(.red)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.leadingArrowTerminalPoint.x,
                                y: text.leadingArrowTerminalPoint.y
                            )

                        Circle()
                            .foregroundStyle(.blue)
                            .frame(width: 10, height: 10)
                            .position(
                                x: text.trailingArrowTerminalPoint.x,
                                y: text.trailingArrowTerminalPoint.y
                            )
                    }
                }
            }
        } // ZStack
    }
}
