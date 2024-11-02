//
//  IndexView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import SwiftUI
import TypeDeclaration

struct IndexView: View {
    let object: any HasHeader

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
        case is ActorObject:
            return Color("Actor", bundle: .module)
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
        case is ActorObject:
            return "Actor"
        default:
            fatalError()
        }
    }

    var body: some View {
        ZStack {
            IndexFrameShape()
                .fill(indexColor)
                .frame(
                    width: ComponentSizeValues.headerIndexWidth,
                    height: ComponentSizeValues.itemHeight
                )

            IndexFrameShape()
                .stroke(lineWidth: ComponentSizeValues.borderWidth)
                .fill(.black)
                .frame(
                    width: ComponentSizeValues.headerIndexWidth,
                    height: ComponentSizeValues.itemHeight
                )

            Text(text)
                .font(.system(size: ComponentSizeValues.fontSize))
                .frame(
                    width: ComponentSizeValues.headerIndexWidth,
                    height: ComponentSizeValues.itemHeight
                )
        } // ZStack
    }
}

#Preview {
    Group {
        IndexView(
            object: ProtocolObject(
                name: "SampleProtocol",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )
        )
        .frame(width: 350, height: 140)

        IndexView(
            object: StructObject(
                name: "SampleStruct",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )
        )
        .frame(width: 350, height: 140)

        IndexView(
            object: ClassObject(
                name: "SampleClass",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )
        )
        .frame(width: 350, height: 140)

        IndexView(
            object: EnumObject(
                name: "SampleEnum",
                nameOffset: 0,
                fullPath: "",
                sourceCode: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )
        )
        .frame(width: 350, height: 140)

        IndexView(
            object: ActorObject(
                name: "SampleActor",
                nameOffset: 0,
                fullPath: "",
                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
                offsetRange: 0 ... 1
            )
        )
    }
}
