//
//  RAGESSView.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import ComposableArchitecture
import DebugView
import FileTreeView
import SwiftDiagramView
import SwiftUI

public struct RAGESSView: View {
    @Bindable private var store: StoreOf<RAGESSReducer>

    // FIXME: If Reducer manages this state, the `.fileImporter` will be opened only once.
    @State private var isShowRootDirectorySelector = false
    @State private var isShowDerivedDataSelector = false

    public init(store: StoreOf<RAGESSReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            NavigationSplitView(
                sidebar: {
                    VStack(alignment: .leading) {
                        Divider()

                        HStack(spacing: 10) {
                            TextField("YourApp", text: $store.extractedData.projectRootDirectoryPath)

                            Button(
                                action: {
                                    isShowRootDirectorySelector = true
                                },
                                label: {
                                    Image(systemName: "folder")
                                }
                            )
                            .fileImporter(
                                isPresented: $isShowRootDirectorySelector,
                                allowedContentTypes: [.directory],
                                allowsMultipleSelection: false
                            ) { result in
                                store.send(.projectDirectorySelectorResponse(result))
                            }
                        }
                        .padding(.horizontal, 10)

                        HStack(spacing: 10) {
                            TextField("DerivedData/YourApp-hash", text: $store.extractedData.derivedDataPath)

                            Button(
                                action: {
                                    isShowDerivedDataSelector = true
                                },
                                label: {
                                    Image(systemName: "folder")
                                }
                            )
                            .fileImporter(
                                isPresented: $isShowDerivedDataSelector,
                                allowedContentTypes: [.directory],
                                allowsMultipleSelection: false
                            )
                            { result in
                                store.send(.derivedDataSelectorResponse(result))
                            }
                        }
                        .padding(.horizontal, 10)

                        #if DEBUG
                            Divider()
                            DebugView(store: store.scope(state: \.debugView, action: \.debugView))
                            Divider()
                        #endif

                        Text("Build Start: \(store.lastBuildStartTimeString)")
                            .padding(.horizontal)
                        Text("Build Success: \(store.lastBuildSuccessTimeString)")
                            .padding(.horizontal)
                        Divider()

                        if let _ = store.fileTree.rootDirectory {
                            FileTreeView(store: store.scope(state: \.fileTree, action: \.fileTree))
                                .padding(.leading, 20)
                        }

                        Spacer()
                    }
                },
                detail: {
                    VStack(spacing: 0) {
//                        HStack(spacing: 0) {
//                            Spacer()
//
//                            Button(
//                                action: {
//                                    store.send(.minusMagnifyingglassTapped)
//                                },
//                                label: {
//                                    Image(systemName: "minus.magnifyingglass")
//                                }
//                            )
//                            .padding(.leading)
//
//                            Text("\(Int(store.swiftDiagramTree.swiftDiagramScale * 100))%")
//                                .frame(width: 50)
//
//                            Button(
//                                action: {
//                                    store.send(.plusMagnifyingglassTapped)
//                                },
//                                label: {
//                                    Image(systemName: "plus.magnifyingglass")
//                                }
//                            )
//                            .padding(.trailing)
//                        } // HStack
//                        .frame(height: 40)

//                        Divider()

                        SwiftDiagramTreeView(store: store.scope(state: \.swiftDiagramTree, action: \.swiftDiagramTree))

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
    }
}
