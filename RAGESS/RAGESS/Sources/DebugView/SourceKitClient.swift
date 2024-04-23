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
        var cursorInfoResponse = CursorInfoResponse()

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
        case cursorInfoResponse(Result<[String: SourceKitRepresentable], Error>)
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
                for (key, value) in response {
                    if let cursorInfoKey = CursorInfoResponseKeys(key: key) {
                        switch cursorInfoKey {
                        case .name:
                            state.cursorInfoResponse.name = value as? String
                        case .kind:
                            state.cursorInfoResponse.kind = value as? String
                        case .length:
                            state.cursorInfoResponse.length = value as? Int64
                        case .declLang:
                            state.cursorInfoResponse.declLang = value as? String
                        case .typeName:
                            state.cursorInfoResponse.typeName = value as? String
                        case .annotatedDecl:
                            state.cursorInfoResponse.annotatedDecl = value as? String
                        case .fullyAnnotatedDecl:
                            state.cursorInfoResponse.fullyAnnotatedDecl = value as? String
                        case .filePath:
                            state.cursorInfoResponse.filePath = value as? String
                        case .moduleName:
                            state.cursorInfoResponse.moduleName = value as? String
                        case .line:
                            state.cursorInfoResponse.line = value as? Int64
                        case .column:
                            state.cursorInfoResponse.column = value as? Int64
                        case .offset:
                            state.cursorInfoResponse.offset = value as? Int64
                        case .USR:
                            state.cursorInfoResponse.USR = value as? String
                        case .typeUSR:
                            state.cursorInfoResponse.typeUSR = value as? String
                        case .containerTypeUSR:
                            state.cursorInfoResponse.containerTypeUSR = value as? String
                        case .reusingASTContext:
                            state.cursorInfoResponse.reusingASTContext = value as? Bool
                        }
                    } else {
                        fatalError("Unexpected Response [\(key): \(value)]")
                    }
                }
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
                    HStack(alignment: .top) {
                        Text("key.name:")
                        Text(store.cursorInfoResponse.name ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.kind:")
                        Text(store.cursorInfoResponse.kind ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.length:")
                        if let length = store.cursorInfoResponse.length {
                            Text("\(length)")
                        }
                        Spacer()
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("key.decl_lang:")
                        Text(store.cursorInfoResponse.declLang ?? "")
                        Spacer()
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("key.typename:")
                        Text(store.cursorInfoResponse.typeName ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.annotated_decl:")
                        Text(store.cursorInfoResponse.annotatedDecl ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.fully_annotated_decl:")
                        Text(store.cursorInfoResponse.fullyAnnotatedDecl ?? "")
                        Spacer()
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("key.filepath:")
                        Text(store.cursorInfoResponse.filePath ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.modulename:")
                        Text(store.cursorInfoResponse.moduleName ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.line:")
                        if let line = store.cursorInfoResponse.line {
                            Text("\(line)")
                        }
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.column:")
                        if let column = store.cursorInfoResponse.column {
                            Text("\(column)")
                        }
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.offset:")
                        Text("\(store.cursorInfoResponse.offset?.description ?? "")")
                        Spacer()
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("key.usr:")
                        Text(store.cursorInfoResponse.USR ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.typeusr:")
                        Text(store.cursorInfoResponse.typeUSR ?? "")
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Text("key.containertypeusr:")
                        Text(store.cursorInfoResponse.containerTypeUSR ?? "")
                        Spacer()
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("key.reusingastcontext:")
                        Text("\(store.cursorInfoResponse.reusingASTContext?.description ?? "")")
                        Spacer()
                    }
                } header: {
                    Text("Request")
                        .font(.headline)
                }
            }

            Spacer()
        }
    }
}
