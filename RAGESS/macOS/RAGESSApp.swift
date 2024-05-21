//
//  RAGESSApp.swift
//  RAGESS
//
//  Created by ockey12 on 2024/04/06.
//

import RAGESSView
import SwiftUI

@main
struct RAGESSApp: App {
    var body: some Scene {
        WindowGroup {
            RAGESSView(
                store: .init(
                    initialState: .init(projectRootDirectoryPath: ""),
                    reducer: {
                        RAGESSReducer()
                    }
                )
            )
        }
    }
}
