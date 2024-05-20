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
        Button(
            action: {
                store.send(.projectDirectorySelectorButtonTapped)
            },
            label: {
                Image(systemName: "folder.badge.plus")
            }
        )
        .fileImporter(
            isPresented: $store.isShowRootDirectorySelector,
            allowedContentTypes: [.directory],
            allowsMultipleSelection: false) { result in
                store.send(.projectDirectorySelectorResponse(result))
            }
    }
}
