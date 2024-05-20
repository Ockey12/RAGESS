//
//  FileTreeView.swift
//
//  
//  Created by Ockey12 on 2024/05/21
//  
//

import ComposableArchitecture
import SwiftUI
import XcodeObject

struct FileTreeView: View {
    @Bindable var store: StoreOf<RAGESSReducer>
    let directory: Directory

    init(store: StoreOf<RAGESSReducer>, directory: Directory) {
        self.store = store
        self.directory = directory
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if directory.files.isEmpty,
                   directory.subDirectories.isEmpty {
                    Image(systemName: "folder")
                } else {
                    Image(systemName: "folder.fill")
                }
                Text(directory.name)
                Spacer()
            }
            .frame(height: 20)
            VStack(spacing: 0) {
                ForEach(directory.files) { file in
                    HStack {
                        Button(
                            action: {
                                store.send(.sourceFileSelected(file))
                            },
                            label: {
                                HStack {
                                    Image(systemName: "swift")
                                        .foregroundStyle(.orange)
                                    Text(file.name)
                                }
                            }
                        )
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .frame(height: 20)
                }
                ForEach(directory.subDirectories) { subDirectory in
                    FileTreeView(store: store, directory: subDirectory)
                }
            }
            .padding(.leading, 24)
        }
    }
}
