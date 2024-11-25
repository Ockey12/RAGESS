//
//  DependenciesExtractorDebugger.swift
//
//
//  Created by Ockey12 on 2024/11/19
//
//

import ComposableArchitecture
import DeclarationExtractor
import DependenciesExtractor
import Foundation
import SourceFileClient
import SwiftUI
import XcodeObject

@Reducer
public struct DependenciesExtractorDebugger {
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
        BindingReducer()
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
                case let .success(rootDirectory):
                    guard let indexStorePath = URL(string: state.indexStorePath) else {
                        assertionFailure()
                        return .none
                    }

                    let declarationExtractor = DeclarationExtractor()
                    do {
                        let startTime = CFAbsoluteTimeGetCurrent()

                        let response = try declarationExtractor.extractDeclarations(rootDirectory: rootDirectory, indexStoreURL: indexStorePath)
                        print("\nCOMPLETE DeclarationExtractor.extractDeclarations(): \(CFAbsoluteTimeGetCurrent() - startTime) S: \(response.usrTable.count) usrTable items")
                        let numOfDefinitions = response.indexStoreObjects.filter { $0.role == .definition }.count
                        let numOfReferences = response.indexStoreObjects.filter { $0.role == .reference }.count
                        print(numOfDefinitions, "definitions")
                        print(numOfReferences, "references")

                        let dependenciesTable = DependenciesExtractor.extract(
                            indexStoreObjects: response.indexStoreObjects,
                            usrTable: response.usrTable,
                            sourceFileTable: response.sourceFileTable,
                            rootDirectory: response.rootDirectory
                        )

                        let endTime = CFAbsoluteTimeGetCurrent()
                        print("\nCOMPLETE DependenciesExtractor.extract(): \(endTime - startTime) S: \(dependenciesTable.count) dependenciesTable items")
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

public struct DependenciesExtractorDebugView: View {
    @Bindable private var store: StoreOf<DependenciesExtractorDebugger>

    public init(store: StoreOf<DependenciesExtractorDebugger>) {
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
                Text("DependenciesExtractor.extract()")
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
