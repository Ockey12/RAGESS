//
//  KittenClient.swift
//
//
//  Created by ockey12 on 2024/04/21.
//

import ComposableArchitecture
import KittenClient
import SwiftUI

@Reducer
public struct KittenClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var filePath: String
        var symbolName: String = ""

        public init(filePath: String) {
            self.filePath = filePath
        }
    }

    public enum Action: BindableAction {
        case dumpSymbolTapped
        case initializeResponse(Result<FileStructureDebugger, Error>)
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .dumpSymbolTapped:
                return .run { [filePath = state.filePath] send in
                    await send(.initializeResponse(Result {
                        try FileStructureDebugger(filePath: filePath)
                    }))
                }

            case let .initializeResponse(.success(jumpToDefinition)):
                jumpToDefinition.printStructure()
                return .none

            case let .initializeResponse(.failure(error)):
                print(error)
                return .none

            case .binding:
                return .none
            }
        }
    }
}

public struct KittenClientDebugView: View {
    @Bindable public var store: StoreOf<KittenClientDebugger>

    public init(store: StoreOf<KittenClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text(store.filePath)

            Form {
                TextField("Symbol Name", text: $store.symbolName)
                Button("Dump Symbol") {
                    store.send(.dumpSymbolTapped)
                }
            }
        }
    }
}
