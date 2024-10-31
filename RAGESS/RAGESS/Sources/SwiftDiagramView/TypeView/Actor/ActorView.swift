//
//  ActorView.swift
//
//  
//  Created by Ockey12 on 2024/11/01
//  
//

import ComposableArchitecture
import SwiftUI


public struct ActorView: View {
    let store: StoreOf<ActorViewReducer>

    public init(store: StoreOf<ActorViewReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: -ComponentSizeValues.connectionHeight) {
            HeaderView(store: store.scope(state: \.header, action: \.header))

            ForEach(store.scope(state: \.details, action: \.details)) { detailStore in
                if !detailStore.texts.isEmpty {
                    DetailView(store: detailStore)
                }
            }
        }
        .frame(width: store.frameWidth, height: store.frameHeight)
        .offset(x: store.topLeadingPoint.x, y: store.topLeadingPoint.y)
    }
}
