//
//  FileTreePopover.swift
//
//
//  Created by Ockey12 on 2024/07/15
//
//

import ComposableArchitecture
import DeclaredObject
import SwiftUI

@Reducer
public struct FileTreePopoverReducer {
    @ObservableState
    public struct State {
        let content: Content
        var cells: IdentifiedArrayOf<FileTreePopoverCellReducer.State>

        public init(content: Content) {
            self.content = content

            switch content {
            case .directory:
                cells = []
                break
            case let .sourceFile(sourceFile):
                let objects = sourceFile.declaredObjects.sorted(by: { $0.rangeInXcode.lowerBound < $1.rangeInXcode.lowerBound })
                cells = .init(uniqueElements: objects.map {
                    FileTreePopoverCellReducer.State(declaredObject: $0)
                })
            }
        }
    }

    public enum Action {
        case cells(IdentifiedActionOf<FileTreePopoverCellReducer>)
        case delegate(Delegate)

        public enum Delegate {
            case cellClicked(objectID: UUID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .cells(.element(id: _, action: .delegate(delegateAction))):
                switch delegateAction {
                case let .clicked(objectID: objectID):
                    return .send(.delegate(.cellClicked(objectID: objectID)))
                }

            case .cells:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.cells, action: \.cells) {
            FileTreePopoverCellReducer()
        }
    }
}

public struct FileTreePopoverContentView: View {
    let store: StoreOf<FileTreePopoverReducer>

    public init(store: StoreOf<FileTreePopoverReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.scope(state: \.cells, action: \.cells)) { cellStore in
                FileTreePopoverCell(store: cellStore)
                    .listRowSeparator(.hidden)
            }
        }
    }
}
