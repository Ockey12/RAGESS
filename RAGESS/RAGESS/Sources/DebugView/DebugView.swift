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
        var typeDeclarationExtractorDebugger = DeclarationExtractorDebugger.State()
        var dependenciesExtractorDebugger = DependenciesExtractorDebugger.State()

        public init() {}
    }

    public enum Action {
        case swiftIndexStoreClientDebugger(SwiftIndexStoreClientDebugger.Action)
        case typeDeclarationExtractorDebugger(DeclarationExtractorDebugger.Action)
        case dependenciesExtractorDebugger(DependenciesExtractorDebugger.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.swiftIndexStoreClientDebugger, action: \.swiftIndexStoreClientDebugger) {
            SwiftIndexStoreClientDebugger()
        }
        Scope(state: \.typeDeclarationExtractorDebugger, action: \.typeDeclarationExtractorDebugger) {
            DeclarationExtractorDebugger()
        }
        Scope(state: \.dependenciesExtractorDebugger, action: \.dependenciesExtractorDebugger) {
            DependenciesExtractorDebugger()
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

            Divider()

            TypeDeclarationExtractorDebugView(
                store: store.scope(
                    state: \.typeDeclarationExtractorDebugger,
                    action: \.typeDeclarationExtractorDebugger
                )
            )

            Divider()

            DependenciesExtractorDebugView(
                store: store.scope(
                    state: \.dependenciesExtractorDebugger,
                    action: \.dependenciesExtractorDebugger
                )
            )
        }
    }
}
