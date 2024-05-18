//
//  DeclarationExtractor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import ComposableArchitecture
import DeclarationExtractor
import SwiftUI
import TypeDeclaration
import XcodeObject

@Reducer
public struct TypeDeclarationExtractorDebugger {
    @ObservableState
    public struct State {
        var directory: Directory
        var buildSettings: [String: String]
        var packages: [PackageObject]
        var declarationObjects: [any DeclarationObject]

        public init(
            directory: Directory,
            buildSettings: [String: String],
            packages: [PackageObject],
            declarationObjects: [any DeclarationObject]
        ) {
            self.directory = directory
            self.buildSettings = buildSettings
            self.packages = packages
            self.declarationObjects = declarationObjects
        }
    }

    public enum Action {
        case extractTapped
        case extractResponse([any DeclarationObject])
        case extractionCompleted
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .extractTapped:
                state.declarationObjects = []
                let extractor = DeclarationExtractor()
//                var declarationObjects: [any DeclarationObject] = []
//                for sourceFile in getAllSourceFiles(in: state.directory) {
//                    declarationObjects.append(
//                        contentsOf: extractor.extra
//                    )
//                }
//                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
//                print("TypeDeclarationExtractorDebugger.Action.extractTapped")
//                dump(declarationObjects)
//                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
//                return .none
                let allSourceFiles = getAllSourceFiles(in: state.directory)
                let allSourceFilePaths = allSourceFiles.map { $0.path }
                return .run {
                    [
                        buildSettings = state.buildSettings,
                        packages = state.packages
                    ] send in
                    for sourceFile in allSourceFiles {
                        await send(.extractResponse(
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

            case let .extractResponse(objects):
                state.declarationObjects.append(contentsOf: objects)
                return .none

            case .extractionCompleted:
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                print("EXTRACT DECLARATIONS COMPLETED")
                dump(state.declarationObjects)
                print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=\n")
                return .none
            }
        }
    }
}

extension TypeDeclarationExtractorDebugger {
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
