//
//  TextCellView.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import SwiftUI

struct TextCellView: View {
    let text: String
    let bodyWidth: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: ComponentSizeValues.fontSize))
            .foregroundStyle(.black)
            .padding(.leading, ComponentSizeValues.textLeadingPadding)
            .offset(x: ComponentSizeValues.arrowTerminalWidth)
            .frame(
                width: bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                height: ComponentSizeValues.itemHeight,
                alignment: .leading
            )
            .onTapGesture {

            }
    }
}

#Preview {
    TextCellView(text: "Title", bodyWidth: 800)
}
