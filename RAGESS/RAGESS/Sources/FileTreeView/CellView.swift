//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/13
//  
//

import ComposableArchitecture
import SwiftUI
import TypeDeclaration

@Reducer
struct CellReducer {
    @ObservableState
    struct State: Identifiable {
        var id: UUID {
            declarationObject.id
        }
        let declarationObject: any DeclarationObject
    }
}

struct CellView: View {
    let store: StoreOf<CellReducer>

    init(store: StoreOf<CellReducer>) {
        self.store = store
    }

    var body: some View {
        Text(store.declarationObject.annotatedDecl)
    }
}
