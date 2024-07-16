//
//  FileTreePopoverCell.swift
//
//
//  Created by Ockey12 on 2024/07/17
//
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

@Reducer
public struct FileTreePopoverCellReducer {
    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            declarationObject.id
        }

        let declarationObject: any DeclarationObject
    }
}

struct FileTreePopoverCell: View {
    let store: StoreOf<FileTreePopoverCellReducer>

    var body: some View {
        Text(store.declarationObject.annotatedDecl)
    }
}
