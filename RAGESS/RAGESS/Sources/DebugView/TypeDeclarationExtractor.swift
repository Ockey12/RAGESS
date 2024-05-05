//
//  TypeDeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import ComposableArchitecture
import SwiftUI
import TypeDeclarationExtractor
import XcodeObject

@Reducer
public struct TypeDeclarationExtractorDebugger {
    @ObservableState
    public struct State {
        var directory: Directory

        public init(directory: Directory) {
            self.directory = directory
        }
    }

    public enum Action {
        case extractTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .extractTapped:
                let extractor = TypeDeclarationExtractor()
                for sourceFile in getAllSourceFiles(in: state.directory) {
                    _ = extractor.extract(from: sourceFile)
                }
                return .none
            }
        }
    }

    func getAllSourceFiles(in directory: Directory) -> [SourceFile] {
        var sourceFiles = directory.files
        for subDirectory in directory.subDirectories {
            sourceFiles.append(contentsOf: getAllSourceFiles(in: subDirectory))
        }

        return sourceFiles
    }
}

struct TypeDeclarationExtractorDebugView: View {
    let store: StoreOf<TypeDeclarationExtractorDebugger>

    init(store: StoreOf<TypeDeclarationExtractorDebugger>) {
        self.store = store
    }

    var body: some View {
        Button("Extract") {
            store.send(.extractTapped)
        }
    }
}
