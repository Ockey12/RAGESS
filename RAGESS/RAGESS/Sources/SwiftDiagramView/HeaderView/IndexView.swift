//
//  IndexView.swift
//
//
//  Created by Ockey12 on 2024/05/22
//
//

import DeclaredObject
import SwiftUI

struct IndexView: View {
    let object: DeclaredObject

    var indexColor: Color {
        switch object.kind {
        case .struct:
//            return Color(red: 0.15, green: 1, blue: 0)
            return Color("StructIndex", bundle: .module)
        case .class:
//            return Color(red: 1, green: 0.7, blue: 0)
            return Color("ClassIndex", bundle: .module)
        case .enum:
//            return Color(red: 0, green: 0.7, blue: 0.85)
            return Color("EnumIndex", bundle: .module)
        case .protocol:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .actor:
            return Color("ActorIndex", bundle: .module)
        case .extension:
            return .clear
        default:
            assertionFailure()
            return .clear
        }
    }

    var text: String {
        switch object.kind {
        case .struct:
            return "Struct"
        case .class:
            return "Class"
        case .enum:
            return "Enum"
        case .protocol:
            return "Protocol"
        case .actor:
            return "Actor"
        case .extension:
            return "Extension"
        default:
            assertionFailure()
            return ""
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
                .fill(Color("ComponentBorder", bundle: .module))
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

// #Preview {
//    Group {
//        IndexView(
//            object: ProtocolObject(
//                name: "SampleProtocol",
//                nameOffset: 0,
//                fullPath: "",
//                sourceCode: "",
//                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//                offsetRange: 0 ... 1
//            )
//        )
//        .frame(width: 350, height: 140)
//
//        IndexView(
//            object: StructObject(
//                name: "SampleStruct",
//                nameOffset: 0,
//                fullPath: "",
//                sourceCode: "",
//                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//                offsetRange: 0 ... 1
//            )
//        )
//        .frame(width: 350, height: 140)
//
//        IndexView(
//            object: ClassObject(
//                name: "SampleClass",
//                nameOffset: 0,
//                fullPath: "",
//                sourceCode: "",
//                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//                offsetRange: 0 ... 1
//            )
//        )
//        .frame(width: 350, height: 140)
//
//        IndexView(
//            object: EnumObject(
//                name: "SampleEnum",
//                nameOffset: 0,
//                fullPath: "",
//                sourceCode: "",
//                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//                offsetRange: 0 ... 1
//            )
//        )
//        .frame(width: 350, height: 140)
//
//        IndexView(
//            object: ActorObject(
//                name: "SampleActor",
//                nameOffset: 0,
//                fullPath: "",
//                positionRange: SourcePosition(line: 0, utf8index: 0) ... SourcePosition(line: 1, utf8index: 1),
//                offsetRange: 0 ... 1
//            )
//        )
//    }
// }
