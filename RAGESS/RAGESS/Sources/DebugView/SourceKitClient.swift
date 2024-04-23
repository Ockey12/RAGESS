//
//  SourceKitClient.swift
//
//
//  Created by ockey12 on 2024/04/21.
//

import ComposableArchitecture
import LSPClient
import SourceKitClient
import SourceKittenFramework
import SwiftUI

@Reducer
public struct SourceKitClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var filePath: String
        var symbolName: String = ""
        var countedString: String = ""
        var offset: Int = 0

        public init(filePath: String) {
            self.filePath = filePath
        }
    }

    public enum Action: BindableAction {
        case dumpSymbolTapped
        case initializeResponse(Result<FileStructureDebugger, Error>)
        case getTrailingOffsetTapped
        case offsetResponse(Result<Int, Error>)
        case cursorInfoTapped
        case cursorInfoResponse(Result<[String : SourceKitRepresentable], Error>)
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

            case .getTrailingOffsetTapped:

                return .run { [string = state.countedString] send in
                    let position = string.lastPosition
                    await send(.offsetResponse(Result {
                        try string.getByteOffset(position: position)
                    }))
                }

            case let .offsetResponse(.success(offset)):
                state.offset = offset
                return .none

            case let .offsetResponse(.failure(error)):
                print(error)
                return .none

            case .cursorInfoTapped:
                return .run { [path = state.filePath, offset = state.offset] send in
                    await send(.cursorInfoResponse(Result {
                        try await sourceKitClient.sendCursorInfoRequest(
                            file: path,
                            offset: offset,
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
                                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk",
                                "-sdk",
                                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk"
                            ]
                        )
                    }))
                }

            case let .cursorInfoResponse(.success(response)):
                return .none

            case let .cursorInfoResponse(.failure(error)):
                print(error)
                return .none

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
            Text("File Path: \(store.filePath)")

            Form {
                TextField("Symbol Name", text: $store.symbolName)
                Button("Dump Symbol") {
                    store.send(.dumpSymbolTapped)
                }
                Section {
                    TextEditor(text: $store.countedString)
                        .frame(height: 300)
                    Button("Get Trailing Offset") {
                        store.send(.getTrailingOffsetTapped)
                    }
                    Text("Offset: \(store.offset)")
                } header: {
                    Text("Offset")
                        .font(.headline)
                }
                Section {
                    Button("Cursor Info") {
                        store.send(.cursorInfoTapped)
                    }
                    Text("key.name: ")
                    Text("key.kind: ")
                    Text("key.length: ")
                    Divider()
                    Text("key.decl_lang: ")
                    Divider()
                    Text("key.typename:")
                    Text("key.annotated_decl: ")
                    Text("key.fully_annotated_decl: ")
                    Divider()
                    Text("key.filepath: ")
                    Text("key.modulename: ")
                    Text("key.line: ")
                    Text("key.column: ")
                    Text("key.offset: ")
                    Divider()
                    Text("key.usr: ")
                    Text("key.typeusr: ")
                    Text("key.containertypeusr: ")
                    Divider()
                    Text("key.reusingastcontext: ")
                } header: {
                    Text("Request")
                        .font(.headline)
                }
            }

            Spacer()
        }
    }
}
