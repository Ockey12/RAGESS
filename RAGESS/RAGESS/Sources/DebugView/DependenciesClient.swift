//
//  DependenciesClient.swift
//
//
//  Created by Ockey12 on 2024/05/15
//
//

import ComposableArchitecture
import DependenciesClient
import SourceKitClient
import SwiftUI
import TypeDeclaration
import TypeDeclarationExtractor
import XcodeObject

@Reducer
public struct DependenciesClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var declarationObjects: [any DeclarationObject]
        var allSourceFiles: [SourceFile]
        var buildSettings: [String: String]
        var packages: [PackageObject]

        public init(
            declarationObjects: [any DeclarationObject],
            allSourceFiles: [SourceFile],
            buildSettings: [String: String],
            packages: [PackageObject]
        ) {
            self.declarationObjects = declarationObjects
            self.allSourceFiles = allSourceFiles
            self.buildSettings = buildSettings
            self.packages = packages
        }
    }

    public enum Action {
        case getDependenciesTapped
        case extractDependenciesResponse(Result<[any DeclarationObject], Error>)
    }

    @Dependency(DependenciesClient.self) var dependenciesClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .getDependenciesTapped:
                let extractor = DeclarationExtractor()
                var declarationObjects: [any DeclarationObject] = []
                for sourceFile in state.allSourceFiles {
                    declarationObjects.append(
                        contentsOf: extractor.extractDeclarations(from: sourceFile)
                    )
                }
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                print("TypeDeclarationExtractorDebugger.Action.extractTapped")
                dump(declarationObjects)
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
                return .run {
                    [
                        declarationObjects = declarationObjects,
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
