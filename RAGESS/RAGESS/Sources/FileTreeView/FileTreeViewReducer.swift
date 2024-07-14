//
//  File.swift
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
    @ObservableState
    public struct State {
        let rootDirectory: Directory
        var cells: IdentifiedArrayOf<CellReducer.State>

        public init(rootDirectory: Directory) {
            self.rootDirectory = rootDirectory
            cells = .init(
                uniqueElements: [
                    CellReducer.State(
                        content: .directory(
                            rootDirectory
                        ),
                        leadingPadding: 0,
                        isExpanding: false
                    )
                ]
            )
        }
    }

    public enum Action {
        case cells(IdentifiedActionOf<CellReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cells:
                return .none
            }
        }
        .forEach(\.cells, action: \.cells) {
            CellReducer()
        }
    }
}
