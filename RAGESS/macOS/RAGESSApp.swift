//
//  RAGESSApp.swift
//  RAGESS
//
//  Created by ockey12 on 2024/04/06.
//

import LSPClient
import SwiftUI

@main
struct RAGESSApp: App {
    var body: some Scene {
        WindowGroup {
            DebugView(
                store: .init(
                    initialState: DebugReducer.State(
                        rootPathString: "",
                        filePathString: "",
                        sourceCode: "",
                        line: 0,
                        column: 0
                    ),
                    reducer: {
                        DebugReducer()
                    }
                )
            )
        }
    }
}
