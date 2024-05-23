//
//  SwiftDiagramView.swift
//
//
//  Created by Ockey12 on 2024/05/23
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct SwiftDiagramView: View {
    let store: StoreOf<SwiftDiagramReducer>

    public init(store: StoreOf<SwiftDiagramReducer>) {
        self.store = store
    }

    public var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 100) {
                HStack(alignment: .top, spacing: 100) {
                    ForEach(store.scope(state: \.structs, action: \.structs)) { structStore in
                        StructView(store: structStore)
                    }
                }
                .padding()

                HStack(alignment: .top, spacing: 100) {
                    ForEach(store.scope(state: \.classes, action: \.classes)) { classStore in
                        ClassView(store: classStore)
                    }
                }
                .padding()

                HStack(alignment: .top, spacing: 100) {
                    ForEach(store.scope(state: \.enums, action: \.enums)) { enumStore in
                        EnumView(store: enumStore)
                    }
                }
                .padding()
            }
        }
    }
}
