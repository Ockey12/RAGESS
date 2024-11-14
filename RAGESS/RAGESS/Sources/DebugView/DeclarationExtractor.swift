//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import ComposableArchitecture
import DeclarationExtractor
import SourceFileClient
import SwiftUI
import XcodeObject

@Reducer
public struct TypeDeclarationExtractorDebugger {
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
        case sourceFileClientResponse(Result<Directory, Error>)
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .executeButtonTapped:
                @Dependency(SourceFileClient.self) var sourceFileClient
                let rootDirectoryPath = state.projectRootPath
                return .run { send in
                    await send(.sourceFileClientResponse(Result {
                        try sourceFileClient.getXcodeObjects(
                            rootDirectoryPath: rootDirectoryPath,
                            ignoredDirectories: [
                                "build",
                                ".build",
                                "DerivedData",
                                ".git",
                                ".github",
                                ".swiftpm"
                            ]
                        )
                    }))
                }

            case let .sourceFileClientResponse(result):
                switch result {
                case let .success(directory):
                    guard let indexStorePath = URL(string: state.indexStorePath) else {
                        assertionFailure()
                        return .none
                    }
                    var rootDirectory = directory
                    let extractor = DeclarationExtractor()
                    do {
                        let startTime = CFAbsoluteTimeGetCurrent()
                        let usrTable = try extractor.extractDeclarations(rootDirectory: &rootDirectory, indexStoreURL: indexStorePath)
                        let endTime = CFAbsoluteTimeGetCurrent()
                        print("COMPLETE DeclarationExtractor.extractDeclarations(): \(endTime - startTime) S: \(usrTable.count) usrTable items")
                        if state.isPrintValid {
                            for (key, value) in usrTable {
                                print("| user = \(key) | keyPath = \(value)")
                            }
                        }
                    } catch {
                        print(error)
                        assertionFailure()
                    }
                    return .none
                case .failure:
                    assertionFailure()
                    return .none
                }

            case .binding:
                return .none
            }
        }
    }
}

struct TypeDeclarationExtractorDebugView: View {
    @Bindable private var store: StoreOf<TypeDeclarationExtractorDebugger>

    init(store: StoreOf<TypeDeclarationExtractorDebugger>) {
        self.store = store
    }

    var body: some View {
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
                Text("DeclarationExtractor.extractDeclarations")
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
