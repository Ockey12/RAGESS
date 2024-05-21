//
//  IndexWithText.swift
//
//  
//  Created by Ockey12 on 2024/05/22
//  
//

import SwiftUI
import TypeDeclaration

struct IndexWithText: View {
    let object: any HasHeader

    let width: CGFloat = 300
    let height: CGFloat = 90

    var indexColor: Color {
        switch object {
        case is ProtocolObject:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case is StructObject:
            return Color(red: 0.15, green: 1, blue: 0)
        case is ClassObject:
            return Color(red: 1, green: 0.7, blue: 0)
        case is EnumObject:
            return Color(red: 0, green: 0.7, blue: 0.85)
        default:
            fatalError()
        }
    }

    var text: String {
        switch object {
        case is ProtocolObject:
            return "Protocol"
        case is StructObject:
            return "Struct"
        case is ClassObject:
            return "Class"
        case is EnumObject:
            return "Enum"
        default:
            fatalError()
        }
    }

    var body: some View {
        ZStack {
            IndexFrameShape()
                .fill(indexColor)
                .frame(width: width, height: height)

            IndexFrameShape()
                .stroke(lineWidth: 5)
                .fill(.black)
                .frame(width: width, height: height)

            Text(text)
                .frame(width: width, height: height)
                .font(.system(size: 50))
        } // ZStack
    }
}

#Preview {
    Group {
        IndexWithText(
            object: ProtocolObject(
                name: "SampleProtocol",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0)...SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0...1
            )
        )
        .frame(width: 350, height: 140)

        IndexWithText(
            object: StructObject(
                name: "SampleStruct",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0)...SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0...1
            )
        )
        .frame(width: 350, height: 140)

        IndexWithText(
            object: ClassObject(
                name: "SampleClass",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0)...SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0...1
            )
        )
        .frame(width: 350, height: 140)

        IndexWithText(
            object: EnumObject(
                name: "SampleEnum",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0)...SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0...1
            )
        )
        .frame(width: 350, height: 140)
    }
}
