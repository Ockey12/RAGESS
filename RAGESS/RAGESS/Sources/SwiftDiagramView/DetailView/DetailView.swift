//
//  DetailView.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import ComposableArchitecture
import SwiftUI

struct DetailView: View {
    let strings: [String]
    let bodyWidth: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            DetailFrameShape(bodyWidth: bodyWidth, numberOfItems: strings.count)
                .foregroundStyle(.white)

            DetailFrameShape(bodyWidth: bodyWidth, numberOfItems: strings.count)
                .stroke(lineWidth: ComponentSizeValues.borderWidth)
                .fill(.black)

            Text("Associated Type")
                .font(.system(size: ComponentSizeValues.fontSize))
                .frame(
                    width: bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                    height: ComponentSizeValues.itemHeight
                )

            VStack(alignment: .leading, spacing: 0) {
                ForEach(strings, id: \.self) { string in
                    Text(string)
                        .font(.system(size: ComponentSizeValues.fontSize))
                        .foregroundStyle(.black)
                        .padding(.leading, ComponentSizeValues.textLeadingPadding)
                        .offset(x: ComponentSizeValues.arrowTerminalWidth)
                        .frame(
                            width: bodyWidth + ComponentSizeValues.arrowTerminalWidth * 2,
                            height: ComponentSizeValues.itemHeight,
                            alignment: .leading
                        )
                }
            } // VStack
            .padding(.top, ComponentSizeValues.itemHeight)
        } // ZStack
    }
}

#Preview {
    VStack {
        DetailView(
            strings: [
                "AAAAA",
                "BBBBB",
                "CCCCC",
                "DDDDD",
                "EEEEE"
            ],
            bodyWidth: 800
        )
            .padding()
    }
    .frame(width: 900, height: 800)
}
