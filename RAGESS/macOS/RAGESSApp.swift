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
            DebugView(
                store: .init(
                    initialState: DebugReducer.State(
                        lspClient: .init(
                            rootPathString: "",
                            filePathString: "",
                            sourceCode: "",
                            line: 0,
                            column: 0
                        ),
                        sourceFileClient: .init(
                            rootPathString: "",
                            sourceFiles: []
                        ),
                        typeAnnotationClient: .init(
                            sourceFile: .init(path: "", content: ""),
                            typeAnnotatedCode: ""
                        ),
                        kittenClient: .init(filePath: "")
                    ),
                    reducer: {
                        DebugReducer()
                    }
                )
            )
        }
    }
}
