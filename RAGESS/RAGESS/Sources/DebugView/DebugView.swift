//
//  DebugView.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SwiftUI
import XcodeObject

@Reducer
public struct DebugReducer {
    public init() {}

    @ObservableState
    public struct State {
        var swiftIndexStoreClientDebugger = SwiftIndexStoreClientDebugger.State()

        public init() {}
    }

    public enum Action {
        case swiftIndexStoreClientDebugger(SwiftIndexStoreClientDebugger.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.swiftIndexStoreClientDebugger, action: \.swiftIndexStoreClientDebugger) {
            SwiftIndexStoreClientDebugger()
        }
        Reduce { state, action in
            return .none
        }
    }
}

public struct DebugView: View {
    let store: StoreOf<DebugReducer>

    public init(store: StoreOf<DebugReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            SwiftIndexStoreClientDebugView(
                store: store.scope(
                    state: \.swiftIndexStoreClientDebugger,
                    action: \.swiftIndexStoreClientDebugger
                )
            )
        }
    }
}
