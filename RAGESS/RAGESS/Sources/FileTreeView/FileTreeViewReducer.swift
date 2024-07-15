//
//  FileTreeViewReducer.swift
//
//
//  Created by Ockey12 on 2024/07/13
//
//

import ComposableArchitecture
import TypeDeclaration
import XcodeObject

@Reducer
public struct FileTreeViewReducer {
    public init() {}

    @ObservableState
    public struct State {
        public var rootDirectory: Directory? {
            didSet {
                if let directory = rootDirectory {
                    cells = .init(
                        uniqueElements: [
                            CellReducer.State(
                                content: .directory(
                                    directory
                                ),
                                leadingPadding: 0,
                                isExpanding: false
                            )
                        ]
                    )
                }
            }
        }
        var cells: IdentifiedArrayOf<CellReducer.State>

        public init(rootDirectory: Directory? = nil) {
            self.rootDirectory = rootDirectory
            if let directory = rootDirectory {
                cells = .init(
                    uniqueElements: [
                        CellReducer.State(
                            content: .directory(
                                directory
                            ),
                            leadingPadding: 0,
                            isExpanding: false
                        )
                    ]
                )
            } else {
                cells = []
            }
        }
    }

    public enum Action {
        case cells(IdentifiedActionOf<CellReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .cells(.element(id: id, action: .delegate(delegateAction))):
                switch delegateAction {
                case let .expandChildren(content: content, leadingPadding: leadingPadding):
                    guard var index = state.cells.index(id: id) else {
                        return .none
                    }
                    guard case let .directory(directory) = content else {
                        return .none
                    }

                    index += 1

                    state.cells.insert(
                        contentsOf: IdentifiedArrayOf(uniqueElements: directory.files.map {
                            CellReducer.State(content: .sourceFile($0), leadingPadding: leadingPadding + 37)
                        }),
                        at: index
                    )

                    index += directory.files.count

                    state.cells.insert(
                        contentsOf: IdentifiedArrayOf(uniqueElements: directory.subDirectories.map {
                            CellReducer.State(content: .directory($0), leadingPadding: leadingPadding + 22)
                        }),
                        at: index
                    )

                    return .none

                case let .collapseChildren(content: content):
                    guard case let .directory(directory) = content else {
                        return .none
                    }

                    removeChildrenCell(directory: directory, state: &state)

                    return .none

                case let .nameClicked(content):
                    return .none
                }

            case .cells:
                return .none
            }
        }
        .forEach(\.cells, action: \.cells) {
            CellReducer()
        }
    }

    private func removeChildrenCell(directory: Directory, state: inout State) {
        for file in directory.files {
            state.cells.remove(id: file.id)
        }
        for subDirectory in directory.subDirectories {
            removeChildrenCell(directory: subDirectory, state: &state)
            state.cells.remove(id: subDirectory.id)
        }
    }
}
