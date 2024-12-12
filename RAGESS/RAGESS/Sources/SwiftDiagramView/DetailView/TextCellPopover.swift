//
//  TextCellPopover.swift
//
//  
//  Created by Ockey12 on 2024/12/12
//  
//

import ComposableArchitecture
import DeclaredObject
import SwiftUI

@Reducer
public struct TextCellPopoverReducer {
    @ObservableState
    public struct State {
        let object: DeclaredObject
    }

    public enum Action {
        case showImpactScopeButtonClicked
        case delegate(Delegate)

        public enum Delegate {
            case showImpactScopeButtonClicked(firstUSR: String)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showImpactScopeButtonClicked:
                guard let firstUSR = state.object.usrs.first else {
                    return .none
                }
                return .send(.delegate(.showImpactScopeButtonClicked(firstUSR: firstUSR)))

            case .delegate:
                return .none
            }
        }
    }
}

public struct TextCellPopoverContentView: View {
    let store: StoreOf<TextCellPopoverReducer>

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.object.fullPath)
                .font(.system(size: ComponentSizeValues.fontSize))

            Text("Line: \(store.object.rangeInXcode.lowerBound.line) Col: \(store.object.rangeInXcode.lowerBound.column) - Line: \(store.object.rangeInXcode.upperBound.line) Col: \(store.object.rangeInXcode.upperBound.column)")
                .font(.system(size: ComponentSizeValues.fontSize))

            Button(
                action: {
                    store.send(.showImpactScopeButtonClicked)
                },
                label: {
                    Text("Show Impact Scope")
                        .font(.system(size: ComponentSizeValues.fontSize))
                }
            )
            .frame(maxWidth: 400, alignment: .center)
        }
        .padding(15)
    }
}
