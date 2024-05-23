//
//  ClassView.swift
//
//  
//  Created by Ockey12 on 2024/05/23
//  
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

public struct ClassView: View {
    let store: StoreOf<ClassViewReducer>

    public init(store: StoreOf<ClassViewReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: -ComponentSizeValues.connectionHeight) {
            HeaderView(store: store.scope(state: \.header, action: \.header))

            VStack(spacing: -ComponentSizeValues.connectionHeight) {
                ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                    if !detailStore.items.isEmpty {
                        DetailView(store: detailStore)
                    }
                }
            }
        } // VStack
        .frame(width: store.bodyWidth, height: store.height)
    }
}

#Preview {
    var subClass = ClassObject(
        name: "SubClass",
        nameOffset: 0,
        fullPath: "",
        annotatedDecl: "public class SubClass",
        positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
        offsetRange: 0 ... 1
    )

    let allDeclarationObjects: [any DeclarationObject] = [
        subClass
    ]

    return VStack {
        ClassView(
            store: .init(
                initialState: ClassViewReducer.State(
                    object: subClass,
                    allDeclarationObjects: allDeclarationObjects
                ),
                reducer: {
                    ClassViewReducer()
                }
            )
        )
    }
    .frame(width: 3500, height: 2000)
}
