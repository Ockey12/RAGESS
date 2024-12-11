//
//  FileTreePopoverCell.swift
//
//
//  Created by Ockey12 on 2024/07/17
//
//

import ComposableArchitecture
import DeclaredObject
import SwiftUI

@Reducer
public struct FileTreePopoverCellReducer {
    @ObservableState
    public struct State: Identifiable {
        public var id: UUID {
            declaredObject.id
        }

        let declaredObject: DeclaredObject
    }

    public enum Action {
        case clicked
        case delegate(Delegate)

        public enum Delegate {
            case clicked(firstUSR: String)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clicked:
                guard let firstUSR = state.declaredObject.usrs.first else {
                    return .none
                }
                return .send(.delegate(.clicked(firstUSR: firstUSR)))

            case .delegate:
                return .none
            }
        }
    }
}

struct FileTreePopoverCell: View {
    let store: StoreOf<FileTreePopoverCellReducer>

    var body: some View {
        Text(store.declaredObject.declaration)
            .onTapGesture {
                store.send(.clicked)
            }
    }
}
