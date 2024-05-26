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
        ZStack(alignment: .topLeading) {
            ForEach(store.scope(state: \.protocols, action: \.protocols)) { protocolStore in
                ProtocolView(store: protocolStore)
                #if DEBUG
                    .border(.gray)
                #endif
            }

            ForEach(store.scope(state: \.structs, action: \.structs)) { structStore in
                StructView(store: structStore)
                #if DEBUG
                    .border(.green)
                #endif
            }

            ForEach(store.scope(state: \.classes, action: \.classes)) { classStore in
                ClassView(store: classStore)
                #if DEBUG
                    .border(.orange)
                #endif
            }

            ForEach(store.scope(state: \.enums, action: \.enums)) { enumStore in
                EnumView(store: enumStore)
                #if DEBUG
                    .border(.blue)
                #endif
            }

            ForEach(store.scope(state: \.arrows, action: \.arrows)) { arrow in
                ArrowView(store: arrow)
            }

            Circle()
                .foregroundStyle(.clear)
                .position(x: 10, y: 10)

            #if DEBUG
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
            #endif
        } // ZStack
        .frame(width: store.frameWidth, height: store.frameHeight)
    }
}
