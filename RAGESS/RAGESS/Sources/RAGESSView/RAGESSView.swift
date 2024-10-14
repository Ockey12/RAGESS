//
//  RAGESSView.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import ComposableArchitecture
import FileTreeView
import SwiftDiagramView
import SwiftUI

public struct RAGESSView: View {
    @Bindable private var store: StoreOf<RAGESSReducer>

    // FIXME: If Reducer manages this state, the `.fileImporter` will be opened only once.
    @State private var isShowRootDirectorySelector = false

    public init(store: StoreOf<RAGESSReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            NavigationSplitView(
                sidebar: {
                    Divider()

                    if let _ = store.fileTree.rootDirectory {
                        FileTreeView(store: store.scope(state: \.fileTree, action: \.fileTree))
                            .padding(.leading, 20)
                    }

                    Spacer()
                },
                detail: {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button(
                                action: {
                                    isShowRootDirectorySelector = true
                                },
                                label: {
                                    Image(systemName: "folder")
                                }
                            )
                            .padding()

                            Divider()

                            Text(store.projectRootDirectoryPath)
                                .padding()

                            Spacer()

                            Button(
                                action: {
                                    store.send(.minusMagnifyingglassTapped)
                                },
                                label: {
                                    Image(systemName: "minus.magnifyingglass")
                                }
                            )
                            .padding(.leading)

                            Text("\(Int(store.swiftDiagramScale * 100))%")
                                .frame(width: 50)

                            Button(
                                action: {
                                    store.send(.plusMagnifyingglassTapped)
                                },
                                label: {
                                    Image(systemName: "plus.magnifyingglass")
                                }
                            )
                            .padding(.trailing)
                        } // HStack
                        .frame(height: 40)

                        Divider()

                        ScrollView([.horizontal, .vertical]) {
                            TreeView(store: store.scope(state: \.tree, action: \.tree))
                                .scaleEffect(store.swiftDiagramScale)
                                .frame(
                                    width: max(store.tree.frameWidth * store.swiftDiagramScale, 10),
                                    height: max(store.tree.frameHeight * store.swiftDiagramScale, 10)
                                )
                                .padding(300)
                        }

                        Spacer()
                    } // VStack
                }
            )

            if let currentLoadingTask = store.loadingTaskKindBuffer.first {
                switch currentLoadingTask {
                case .sourceFiles:
                    ProgressView {
                        Text("In the process of extracting the source files.")
                    }

                case .buildSettings:
                    ProgressView {
                        Text("In the process of getting build settings.")
                    }

                case .dumpPackage:
                    ProgressView {
                        Text("In the process of analyzing the package.")
                    }

                case .extractDeclarations:
                    ProgressView {
                        Text("In the process of extracting declarations.")
                    }

                case .extractDependencies:
                    ProgressView {
                        Text("In the process of extracting dependencies.")
                    }
                }
            }
        } // ZStack
        .fileImporter(
            isPresented: $isShowRootDirectorySelector,
            allowedContentTypes: [.directory],
            allowsMultipleSelection: false
        ) { result in
            store.send(.projectDirectorySelectorResponse(result))
        }
    }
}
