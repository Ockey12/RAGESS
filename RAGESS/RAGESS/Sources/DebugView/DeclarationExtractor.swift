//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration
import DeclarationExtractor
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
                let extractor = DeclarationExtractor()
                var declarationObjects: [any DeclarationObject] = []
                for sourceFile in getAllSourceFiles(in: state.directory) {
                    declarationObjects.append(
                        contentsOf: extractor.extractDeclarations(from: sourceFile)
                    )
                }
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                print("TypeDeclarationExtractorDebugger.Action.extractTapped")
                dump(declarationObjects)
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
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
