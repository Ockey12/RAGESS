//
//  TextCellView.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import ComposableArchitecture
import SwiftUI

struct TextCellView: View {
    let store: StoreOf<TextCellReducer>

    var body: some View {
        Text(store.text)
            .font(.system(size: ComponentSizeValues.fontSize))
            .foregroundStyle(.black)
            .padding(.leading, ComponentSizeValues.textLeadingPadding)
            .offset(x: ComponentSizeValues.arrowTerminalWidth)
            .frame(
                width: store.bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                height: ComponentSizeValues.itemHeight,
                alignment: .leading
            )
            .onTapGesture {
                store.send(.clicked)
            }
    }
}

#Preview {
    TextCellView(
        store: .init(
            initialState: TextCellReducer.State(
                text: "TEXT",
                bodyWidth: 800
            ),
            reducer: { TextCellReducer() }
        )
    )
}
