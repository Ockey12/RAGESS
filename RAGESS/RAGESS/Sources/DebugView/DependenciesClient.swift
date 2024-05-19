//
//  DependenciesClient.swift
//
//
//  Created by Ockey12 on 2024/05/15
//
//

import ComposableArchitecture
import DeclarationExtractor
import DependenciesClient
import SourceKitClient
import SwiftUI
import TypeDeclaration
import XcodeObject

@Reducer
public struct DependenciesClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var allSourceFiles: [SourceFile]
        var buildSettings: [String: String]
        var packages: [PackageObject]
        var declarationObjects: [any DeclarationObject] = []

        public init(
            allSourceFiles: [SourceFile],
            buildSettings: [String: String],
            packages: [PackageObject]
        ) {
            self.allSourceFiles = allSourceFiles
            self.buildSettings = buildSettings
            self.packages = packages
        }
    }

    public enum Action {
        case getDependenciesTapped
        case extractDeclarationResponse([any DeclarationObject])
        case extractionCompleted
        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
    }

    @Dependency(DependenciesClient.self) var dependenciesClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .getDependenciesTapped:
                state.declarationObjects = []
                let extractor = DeclarationExtractor()
                let allSourceFilePaths = state.allSourceFiles.map { $0.path }
                return .run {
                    [
                        allSourceFiles = state.allSourceFiles,
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in
                    for sourceFile in allSourceFiles {
                        await send(.extractDeclarationResponse(
                            extractor.extractDeclarations(
                                from: sourceFile,
                                buildSettings: buildSettings,
                                sourceFilePaths: allSourceFilePaths,
                                packages: packages
                            )
                        ))
                    }
                    await send(.extractionCompleted)
                }

            case let .extractDeclarationResponse(objects):
                state.declarationObjects.append(contentsOf: objects)
                return .none

            case .extractionCompleted:
                return .run {
                    [
                        declarationObjects = state.declarationObjects,
                        allSourceFiles = state.allSourceFiles,
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in
                    await send(.extractDependenciesResponse(Result {
                        try await dependenciesClient.extractDependencies(
                            declarationObjects: declarationObjects,
                            allSourceFiles: allSourceFiles,
                            buildSettings: buildSettings,
                            packages: packages
                        )
                    }))
                }

            case let .extractDependenciesResponse(.success(declarationObjects)):
                return .none

            case let .extractDependenciesResponse(.failure(error)):
                print(error)
                return .none
            }
        }
    }
}

public struct DependenciesClientDebugView: View {
    let store: StoreOf<DependenciesClientDebugger>

    public init(store: StoreOf<DependenciesClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            Button("Extract Dependencies") {
                store.send(.getDependenciesTapped)
            }
        }
    }
}
