//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import SwiftUI

public struct DebugView: View {
    public init() {}

    public var body: some View {
        TabView {
            LSPClientDebugView(
                store: .init(
                    initialState: LSPClientDebugger.State(
                        rootPathString: "",
                        filePathString: "",
                        sourceCode: "",
                        line: 0,
                        column: 0
                    ),
                    reducer: { LSPClientDebugger() }
                )
            )
            .tabItem { Text("LSPclient") }
            .padding()

            SourceCodeClientDebugView(
                store: .init(
                    initialState: SourceCodeClientDebugger.State(
                        rootPathString: "",
                        sourceFiles: []
                    ),
                    reducer: { SourceCodeClientDebugger() }
                )
            )
            .tabItem { Text("SourceCodeClient") }
            .padding()
        }
        .frame(width: 800)
    }
}
