//
//  RAGESSView.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import ComposableArchitecture
import SwiftUI

public struct RAGESSView: View {
    @Bindable private var store: StoreOf<RAGESSReducer>

    public init(store: StoreOf<RAGESSReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(
                    action: {
                        store.send(.projectDirectorySelectorButtonTapped)
                    },
                    label: {
                        Image(systemName: "folder")
                    }
                )
                .padding()
                .fileImporter(
                    isPresented: $store.isShowRootDirectorySelector,
                    allowedContentTypes: [.directory],
                    allowsMultipleSelection: false
                ) { result in
                    store.send(.projectDirectorySelectorResponse(result))
                }

                Divider()

                Text(store.projectRootDirectoryPath)
                    .padding()

                Spacer()
            } // HStack
            .frame(height: 40)

            Divider()

            Spacer()
        } // VStack
    }
}
