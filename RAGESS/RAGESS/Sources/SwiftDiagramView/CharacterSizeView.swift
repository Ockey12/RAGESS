//
//  CharacterSizeView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import SwiftUI

struct CharacterSizeView: View {
    @State private var characterSize: CGSize = .init()

    var body: some View {
        VStack {
            Text("a")
                .font(.system(size: 50))
                .background {
                    GeometryReader { geometry in
                        Path { _ in
                            let size = geometry.size
                            DispatchQueue.main.async {
                                if self.characterSize != size {
                                    self.characterSize = size
                                }
                            }
                        }
                    }
                }
                .border(.pink)

            Text("Width: \(characterSize.width)")
            Text("Height: \(characterSize.height)")
        }
        .frame(width: 300, height: 100)
    }
}

#Preview {
    CharacterSizeView()
}
