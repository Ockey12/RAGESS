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
import XcodeObject

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
        var allFilePathsInProject: [String] = []
        var buildSettings: [String: String] = [:]
        var packages: [PackageObject] = []
        var compilerArguments: [String] {
            [
                "-vfsoverlay",
                "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/index-overlay.yaml",
                "-module-name",
                "DebugView",
                "-Onone",
                "-enforce-exclusivity=checked"
            ]
                + allFilePathsInProject
                + [
                    "-DSWIFT_PACKAGE",
                    "-DDEBUG",
                    "-Xcc",
                    "-fmodule-map-file=/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/GeneratedModuleMaps/SourceKit.modulemap",
                    "-Xcc",
                    "-fmodule-map-file=/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/GeneratedModuleMaps/Clang_C.modulemap",
                    "-DXcode",
                    "-sdk",
                    "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk",
                    "-target",
                    "arm64-apple-macos14.0",
                    "-g",
                    "-module-cache-path",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/ModuleCache.noindex",
                    "-Xfrontend",
                    "-serialize-debugging-options",
                    "-enable-testing",
                    "-swift-version",
                    "5",
                    "-I",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug",
                    "-I",
                    "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib",
                    "-F",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/PackageFrameworks",
                    "-F",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug",
                    "-F",
                    "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks",
                    "-Xfrontend",
                    "-load-plugin-executable",
                    "-Xfrontend",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/CasePathsMacros#CasePathsMacros",
                    "-Xfrontend",
                    "-load-plugin-executable",
                    "-Xfrontend",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/ComposableArchitectureMacros#ComposableArchitectureMacros",
                    "-Xfrontend",
                    "-load-plugin-executable",
                    "-Xfrontend",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/DependenciesMacrosPlugin#DependenciesMacrosPlugin",
                    "-Xfrontend",
                    "-load-plugin-executable",
                    "-Xfrontend",
                    "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/PerceptionMacros#PerceptionMacros",
                    "-Xfrontend",
                    "-experimental-allow-module-with-compiler-errors",
                    "-Xfrontend",
                    "-empty-abi-descriptor",
                    "-Xcc",
                    "-fretain-comments-from-system-headers",
                    "-Xcc",
                    "-Xclang",
                    "-Xcc",
                    "-detailed-preprocessing-record",
                    "-Xcc",
                    "-Xclang",
                    "-Xcc",
                    "-fmodule-format=raw",
                    "-Xcc",
                    "-ferror-limit=10",
                    "-Xcc",
                    "-Xclang",
                    "-Xcc",
                    "-fallow-pch-with-compiler-errors",
                    "-Xcc",
                    "-Xclang",
                    "-Xcc",
                    "-fallow-pcm-with-compiler-errors",
                    "-Xcc",
                    "-Wno-non-modular-include-in-framework-module",
                    "-Xcc",
                    "-Wno-incomplete-umbrella",
                    "-Xcc",
                    "-fmodules-validate-system-headers",
                    "-Xfrontend",
                    "-package-name",
                    "-Xfrontend",
                    "ragess",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/DebugView.build/swift-overrides.hmap",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts/swift-system/Sources/CSystem/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts/swift-tools-support-core/Sources/TSCclibc/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts/Yams/Sources/CYaml/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts/SourceKitten/Source/SourceKit/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts/SourceKitten/Source/Clang_C/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Products/Debug/include",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/DebugView.build/DerivedSources-normal/arm64",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/DebugView.build/DerivedSources/arm64",
                    "-Xcc",
                    "-I/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/DebugView.build/DerivedSources",
                    "-Xcc",
                    "-DSWIFT_PACKAGE",
                    "-Xcc",
                    "-DDEBUG=1",
                    "-working-directory",
                    "/Users/onaga/RAGESS/RAGESS/RAGESS"
                ]
        }

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
        case compilerArgumentsResponse(Result<[String], Error>)
        case cursorInfoResponse(Result<[String: SourceKitRepresentable], Error>)
        case compilerArgumentsGeneratorTapped
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
                state.cursorInfoResponse = CursorInfoResponse()
                print("\nSourceKitClientDebugger")
                dump(state.packages)
                let generator = CompilerArgumentsGenerator(
                    targetFilePath: state.filePath,
                    buildSettings: state.buildSettings,
                    sourceFilePaths: state.allFilePathsInProject,
                    packages: state.packages
                )
                return .run { send in
                    await send(.compilerArgumentsResponse(Result {
                        try await generator.generateArguments()
                    }))
                }

            case let .compilerArgumentsResponse(.success(arguments)):
                print("Compiler Arguments")
                for argument in arguments {
                    print(argument)
                }
                print("")

                let arg = state.compilerArguments
                print("arguments == arg: \(arguments == arg)")

                return .run { [filePath = state.filePath, offset = state.offset, allFilePathsInProject = state.allFilePathsInProject] send in
                    print("\n=====send cursorinfo request=====\n")
                    await send(.cursorInfoResponse(Result {
                        try await sourceKitClient.sendCursorInfoRequest(
                            file: filePath,
                            offset: offset,
                            sourceFilePaths: allFilePathsInProject,
                            arguments: arguments
                        )
                    }))
                }

            case let .compilerArgumentsResponse(.failure(error)):
                print(error)
                return .none

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
                        print("Unexpected Response")
                        dump(response)
                    }
//                    } else {
//                        fatalError("Unexpected Response [\(key): \(value)]")
//                    }
                }
                return .none

            case let .cursorInfoResponse(.failure(error)):
                print(error)
                return .none

            case .compilerArgumentsGeneratorTapped:
//                let generator = CompilerArgumentsGenerator(
//                    targetFilePath: state.filePath,
//                    buildSettings: state.buildSettings,
//                    xcodeprojPath: "",
//                    moduleName: "",
//                    sourceFilePaths: []
//                )
//                print("Start CompilerArgumentsGenerator.getIncludePaths")
//                let includePaths = generator.getIncludePaths(
//                    in: "/Users/onaga/Library/Developer/Xcode/DerivedData/RAGESS-ayjrlzfdtsotsbgxonebesbohntz/SourcePackages/checkouts",
//                    ignoredDirectories: ["swift-package-manager"]
//                )
//                for path in includePaths {
//                    print(path)
//                }
//                print("End CompilerArgumentsGenerator.getIncludePaths")
                for argument in state.compilerArguments {
                    print(argument)
                }
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
        ScrollView {
            Text("File Path: \(store.filePath)")

            Form {
                TextField("Symbol Name", text: $store.symbolName)
                Button("Dump Symbol") {
                    store.send(.dumpSymbolTapped)
                }
                Button("CompilerArgumentsGenerator.resume()") {
                    store.send(.compilerArgumentsGeneratorTapped)
                }
                Section {
                    TextEditor(text: $store.countedString)
                        .frame(height: 700)
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
                    HStack(alignment: .top) {
                        Text("key.modulename:")
                        Text(store.cursorInfoResponse.moduleName ?? "")
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
