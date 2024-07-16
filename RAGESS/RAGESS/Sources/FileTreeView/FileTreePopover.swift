//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/15
//  
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

@Reducer
public struct FileTreePopoverReducer {
    @ObservableState
    public struct State {
        let content: Content
        var declarationObjects: IdentifiedArrayOf<FileTreePopoverCellReducer.State>

        public init(content: Content, declarationObjects: [any DeclarationObject]) {
            self.content = content

            var objects: [any DeclarationObject] = []
            switch content {
                
            case let .directory(directory):
                break
            case let .sourceFile(sourceFile):
                objects = declarationObjects.filter { sourceFile.path == $0.fullPath }
            }
            self.declarationObjects = .init(uniqueElements: objects.map {
                FileTreePopoverCellReducer.State(declarationObject: $0)
            })
        }
    }

    public enum Action {
        case declarationObjects(IdentifiedActionOf<FileTreePopoverCellReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .declarationObjects:
                return .none
            }
        }
        .forEach(\.declarationObjects, action: \.declarationObjects) {
            FileTreePopoverCellReducer()
        }
    }
}

public struct FileTreePopoverContent: View {
    let store: StoreOf<FileTreePopoverReducer>

    public init(store: StoreOf<FileTreePopoverReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.scope(state: \.declarationObjects, action: \.declarationObjects)) { cellStore in
                FileTreePopoverCell(store: cellStore)
                    .listRowSeparator(.hidden)
            }
        }
    }
}
