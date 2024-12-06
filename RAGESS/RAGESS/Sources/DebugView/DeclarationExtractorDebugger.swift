//
//  DeclarationExtractorDebugger.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import ComposableArchitecture
import DeclarationExtractor
import DeclaredObject
import SourceFileClient
import SwiftIndexStoreClient
import SwiftUI
import XcodeObject

@Reducer
public struct DeclarationExtractorDebugger {
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
                        try sourceFileClient.getRootDirectory(
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

                    do {
                        let startTime = CFAbsoluteTimeGetCurrent()
                        let response = try DeclarationExtractor.extractDeclarations(rootDirectory: rootDirectory, indexStoreURL: indexStorePath)
                        let endTime = CFAbsoluteTimeGetCurrent()
                        print("\nCOMPLETE DeclarationExtractor.extractDeclarations(): \(endTime - startTime) S: \(response.usrTable.count) usrTable items")
                        if state.isPrintValid {
                            for (key, value) in response.usrTable {
                                let object = response.rootDirectory[keyPath: value]
                                print("| usr = \(key) | name = \(object.name) | location = \(object.fullPath):\(object.rangeInXcode.lowerBound.line):\(object.rangeInXcode.lowerBound.column)|")
                            }

                            print("\nDIRECTORY STRUCTURE")
                            printStructure(directory: response.rootDirectory, prefix: "", isRoot: true, isLast: true)

                            printUnusedDefinitionUSR(
                                indexStoreURL: indexStorePath,
                                projectRootPath: state.projectRootPath,
                                usrTable: response.usrTable
                            )
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

extension DeclarationExtractorDebugger {
    private func printStructure(directory: Directory, prefix: String, isRoot: Bool, isLast: Bool) {
        if isRoot {
            print("<directory>\(directory.fullPath)")
        } else {
            let branchSymbol = isLast ? "└── " : "├── "
            print("\(prefix)\(branchSymbol)<directory>\(directory.fullPath)")
        }

        let files = directory.files.sorted { $0.name < $1.name }
        let subDirectories = directory.subDirectories.sorted { $0.name < $1.name }

        for (index, file) in files.enumerated() {
            let childPrefix = isRoot ? "" : prefix + (isLast ? "    " : "│   ")
            let isLast = (index == files.endIndex - 1) && (subDirectories.isEmpty)
            printStructure(
                file: file,
                prefix: childPrefix,
                isRoot: false,
                isLast: isLast
            )
        }

        for (index, directory) in subDirectories.enumerated() {
            let childPrefix = isRoot ? "" : prefix + (isLast ? "    " : "│   ")
            printStructure(
                directory: directory,
                prefix: childPrefix,
                isRoot: false,
                isLast: index == subDirectories.endIndex - 1
            )
        }
    }

    private func printStructure(file: SourceFile, prefix: String, isRoot: Bool, isLast: Bool) {
        if isRoot {
            print("<file>\(file.fullPath)")
        } else {
            let branchSymbol = isLast ? "└── " : "├── "
            print("\(prefix)\(branchSymbol)<file>\(file.fullPath)")
        }

        let childObjects = file.declaredObjects.sorted { $0.rangeInXcode.lowerBound < $1.rangeInXcode.lowerBound }
        for (index, child) in childObjects.enumerated() {
            let childPrefix = isRoot ? "" : prefix + (isLast ? "    " : "│   ")
            printStructure(
                declaredObject: child,
                prefix: childPrefix,
                isRoot: false,
                isLast: index == childObjects.endIndex - 1
            )
        }
    }

    private func printStructure(declaredObject: DeclaredObject, prefix: String, isRoot: Bool, isLast: Bool) {
        let range = declaredObject.rangeInXcode
        let location = "\(declaredObject.fullPath)(\(range.lowerBound.line):\(range.lowerBound.column) - \(range.upperBound.line):\(range.upperBound.column))"
        let name = "<\(declaredObject.kind.rawValue)>\(declaredObject.name) \(location)"
        var childObjects = declaredObject.initializers
            + declaredObject.variables
            + declaredObject.functions
            + declaredObject.cases
            + declaredObject.nestingStructs
            + declaredObject.nestingClasses
            + declaredObject.nestingEnums
            + declaredObject.nestingProtocols
            + declaredObject.nestingActors

        if isRoot {
            print(name)
        } else {
            let branchSymbol = isLast ? "└── " : "├── "
            print("\(prefix)\(branchSymbol)\(name)")

            for (index, usr) in declaredObject.usrs.enumerated() {
                print("\(prefix)\(isLast ? "    " : "│   ")\(childObjects.isEmpty ? "" : "│") * USR[\(index)] \(usr)")
            }
        }

        childObjects.sort { $0.rangeInXcode.lowerBound < $1.rangeInXcode.lowerBound }
        for (index, child) in childObjects.enumerated() {
            let childPrefix = isRoot ? "" : prefix + (isLast ? "    " : "│   ")
            printStructure(
                declaredObject: child,
                prefix: childPrefix,
                isRoot: false,
                isLast: index == childObjects.endIndex - 1
            )
        }
    }

    private func printUnusedDefinitionUSR(indexStoreURL: URL, projectRootPath: String, usrTable: USRTable) {
        @Dependency(\.swiftIndexStoreClient) var swiftIndexStoreClient
        guard let unusedUSR = try? swiftIndexStoreClient.extractOccurrences(
            indexStoreURL: indexStoreURL,
            projectRootPath: projectRootPath
        ).filter(
            { $0.roles.contains(.definition) }
        ).filter(
            { !usrTable.keys.contains($0.usr) }
        ) else {
            assertionFailure()
            return
        }

        print("\n\(unusedUSR.count) unused USRs")
        for usr in unusedUSR {
            print("| usr = \(usr.usr) | location = \(usr.fullPath)(\(usr.locationInXcode.line):\(usr.locationInXcode.column)) |")
        }
    }
}

struct TypeDeclarationExtractorDebugView: View {
    @Bindable private var store: StoreOf<DeclarationExtractorDebugger>

    init(store: StoreOf<DeclarationExtractorDebugger>) {
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
