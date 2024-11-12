//
//  SwiftIndexStoreClientDebugger.swift
//
//
//  Created by Ockey12 on 2024/11/12
//
//

import ComposableArchitecture
import Foundation
import SwiftIndexStoreClient
import SwiftUI

@Reducer
public struct SwiftIndexStoreClientDebugger {
    @ObservableState
    public struct State {
        var indexStorePath: String
        var projectRootPath: String
        var isPrintValid: Bool

        public init(
            indexStorePath: String = "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/DataStore",
            projectRootPath: String = "/Users/onaga/RAGESS",
            isPrintValid: Bool = false
        ) {
            self.indexStorePath = indexStorePath
            self.projectRootPath = projectRootPath
            self.isPrintValid = isPrintValid
        }
    }

    public enum Action: BindableAction {
        case executeButtonTapped
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .executeButtonTapped:
                guard let indexStoreURL = URL(string: state.indexStorePath) else {
                    assertionFailure()
                    return .none
                }
                @Dependency(SwiftIndexStoreClient.self) var client
                do {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let definitions = try client.extractDefinitions(indexStoreURL, state.projectRootPath)
                    let endTime = CFAbsoluteTimeGetCurrent()
                    print("COMPLETE SwiftIndexStoreClient.extractDefinitions: \(endTime - startTime)S: \(definitions.count) definitions")
                    if state.isPrintValid {
                        for definition in definitions {
                            print("| user = \(definition.usr) | location = \(definition.fullPath):\(definition.line):\(definition.column)")
                        }
                    }
                } catch {
                    print(error)
                    assertionFailure()
                }
                return .none

            case .binding:
                return .none
            }
        }
    }
}

public struct SwiftIndexStoreClientDebugView: View {
    @Bindable var store: StoreOf<SwiftIndexStoreClientDebugger>

    public init(store: StoreOf<SwiftIndexStoreClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        store.send(.executeButtonTapped)
                    },
                    label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                    }
                )
                Text("SwiftIndexStoreClient.extractDefinitions()")
                    .font(.system(size: 13))
            }

            Toggle(isOn: $store.isPrintValid) {
                Text("Enable printing of results")
                    .font(.system(size: 13))
            }

            HStack {
                Text("Index Store")
                    .font(.system(size: 13))
                TextField("Index Store path", text: $store.indexStorePath)
                    .padding(.horizontal)
            }

            HStack {
                Text("Project")
                    .font(.system(size: 13))
                TextField("project root path", text: $store.projectRootPath)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}
