//
//  RAGESSView.swift
//
//
//  Created by Ockey12 on 2024/05/21
//
//

import SwiftUI

public struct RAGESSView: View {
    @State private var isShowFileImporter = false

    public init() {}

    public var body: some View {
        Button(
            action: {
                isShowFileImporter = true
            },
            label: {
                Image(systemName: "folder.badge.plus")
            }
        )
        .fileImporter(
            isPresented: $isShowFileImporter,
            allowedContentTypes: [.directory],
            allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    print("File import succeeded: \(url.path())")
                case .failure(let error):
                    print("File import error")
                }
            }
    }
}
