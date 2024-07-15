//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/13
//  
//

import ComposableArchitecture
import SwiftUI
import XcodeObject

public struct FileTreeView: View {
    let store: StoreOf<FileTreeViewReducer>

    public init(store: StoreOf<FileTreeViewReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.scope(state: \.cells, action: \.cells)) { cellStore in
                CellView(store: cellStore)
                    .listRowSeparator(.hidden)
            }
        }
    }
}

#Preview {
    FileTreeView(
        store: .init(
            initialState: FileTreeViewReducer.State(
                rootDirectory: Directory(
                    path: "Project/",
                    subDirectories: [
                        Directory(
                            path: "Project/View",
                            subDirectories: [],
                            files: [
                                SourceFile(
                                    path: "Project/View/ContentView.swift",
                                    content: ""
                                )
                            ]
                        ),
                        Directory(
                            path: "Project/Model",
                            subDirectories: [],
                            files: [
                                SourceFile(
                                    path: "Project/Model/DogModel.swift",
                                    content: ""
                                ),
                                SourceFile(
                                    path: "Project/Model/CatModel.swift",
                                    content: ""
                                )
                            ]
                        ),
                        Directory(
                            path: "Project/ViewModel",
                            subDirectories: [],
                            files: [
                                SourceFile(
                                    path: "Project/ViewModel/AnimalViewModel.swift",
                                    content: ""
                                )
                            ]
                        )
                    ],
                    files: [
                        SourceFile(
                            path: "Project/App.swift",
                            content: ""
                        )
                    ]
                )
            ),
            reducer: {
                FileTreeViewReducer()
            }
        )
    )
}
