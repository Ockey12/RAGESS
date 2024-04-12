//
//  RAGESSApp.swift
//  RAGESS
//
//  Created by ockey12 on 2024/04/06.
//

import DebugView
import SwiftUI

@main
struct RAGESSApp: App {
    var body: some Scene {
        WindowGroup {
            LSPClientDebugView(
                store: .init(
                    initialState: LSPClientDebugger.State(
                        rootPathString: "",
                        filePathString: "",
                        sourceCode: "",
                        line: 0,
                        column: 0
                    ),
                    reducer: {
                        LSPClientDebugger()
                    }
                )
            )
        }
    }
}
