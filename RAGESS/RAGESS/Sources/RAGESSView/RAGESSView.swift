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
            NavigationSplitView {
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
                        ) { result in
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
                } // VStack
                .overlay {
                    if store.showProgressView {
                        Color(red: 0, green: 0, blue: 0, opacity: 0.4)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button(
                            action: {
                                store.send(.monitorButtonTapped)
                            },
                            label: {
                                Image(systemName: store.isMonitoring ? "stop.fill" : "play.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        )
                        .disabled(false)
                    }
                }
            } detail: {
                SwiftDiagramTreeView(store: store.scope(state: \.swiftDiagramTree, action: \.swiftDiagramTree))
                    .navigationTitle(store.extractedData.projectRootDirectoryPath)
                    .overlay {
                        if store.showProgressView {
                            Color(red: 0, green: 0, blue: 0, opacity: 0.4)
                        }
                    }
            }

            if store.showProgressView {
                ProgressView()
                    .scaleEffect(2)
            }
        } // ZStack
        .task {
            store.send(.task)
        }
    }
}
