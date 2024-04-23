//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/21.
//

import ComposableArchitecture
import SourceKitClient
import SwiftUI

@Reducer
public struct SourceKitClientDebugger {
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
        case cursorInfoTapped
        case binding(BindingAction<State>)
    }

    @Dependency(SourceKitClient.self) var sourceKitClient

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

            case .cursorInfoTapped:
                return .run { _ in
                    try await sourceKitClient.sendCursorInfoRequest(
                        file: "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Affected.swift",
                        offset: 223,
                        arguments: [
                            "-vfsoverlay",
                            "/Users/onaga/Library/Developer/Xcode/DerivedData/SourceKit-LSP-Analysis-Target-dyojgxcyuvpzjpggswsgjqrcrzqh/Index.noindex/Build/Intermediates.noindex/index-overlay.yaml",
                            "-module-name",
                            "AppFeature",
                            "-Onone",
                            "-enforce-exclusivity=checked",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Affected.swift",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Affecting.swift",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Caller.swift",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Case.swift",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/ContentView.swift",
                            "/Users/onaga/SourceKit-LSP-Analysis-Target/Sources/AppFeature/Sample.swift",
                            "-DSWIFT_PACKAGE",
                            "-DDEBUG",
                            "-DXcode",
                            "-sdk",
//                            "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk"
                            "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk"
                        ]
                    )
                }

            case .binding:
                return .none
            }
        }
    }
}

public struct SourceKitClientDebugView: View {
    @Bindable public var store: StoreOf<SourceKitClientDebugger>

    public init(store: StoreOf<SourceKitClientDebugger>) {
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
                Button("Cursor Info") {
                    store.send(.cursorInfoTapped)
                }
            }
        }
    }
}
