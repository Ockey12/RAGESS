//
//  ExtensionFrame.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/16.
//

import SwiftUI

struct ExtensionFrame: Shape {
    let holder: ConvertedToStringExtensionHolder
    let bodyWidth: CGFloat
    
    var widthFromLeftEdgeToConnection: CGFloat {
        (bodyWidth - connectionWidth) / 2 + extensionOutsidePadding
    }
    
    let connectionWidth = ComponentSettingValues.connectionWidth
    let connectionHeight = ComponentSettingValues.connectionHeight
    let itemHeight = ComponentSettingValues.itemHeight
    let bottomPaddingForLastText = ComponentSettingValues.bottomPaddingForLastText
    let extensionOutsidePadding = ComponentSettingValues.extensionOutsidePadding
    let extensionTopPadding = ComponentSettingValues.extensionTopPadding
    let extensionBottomPadding = ComponentSettingValues.extensionBottomPadding
    let headerItemHeight = ComponentSettingValues.headerItemHeight
    let nestTopPaddingWithConnectionHeight = ComponentSettingValues.nestTopPaddingWithConnectionHeight
    let nestBottomPadding = ComponentSettingValues.nestBottomPadding

    func path(in rect: CGRect) -> Path {
        Path { path in
            // header
            // from right to left
            path.move(to: CGPoint(x: extensionOutsidePadding*2 + bodyWidth, y: connectionHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: connectionHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: 0))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: 0))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: connectionHeight))
            path.addLine(to: CGPoint(x: 0, y: connectionHeight))
            
            // left side
            // from top to bottom
            path.addLine(to: CGPoint(x: 0, y: calculateBodyHeight()))
            
            // footer
            // from left to right
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: calculateBodyHeight()))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection, y: calculateBodyHeight() - connectionHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: calculateBodyHeight() - connectionHeight))
            path.addLine(to: CGPoint(x: widthFromLeftEdgeToConnection + connectionWidth, y: calculateBodyHeight()))
            path.addLine(to: CGPoint(x: extensionOutsidePadding*2 + bodyWidth, y: calculateBodyHeight()))
            
            // right side
            // from bottom to top
            path.addLine(to: CGPoint(x: extensionOutsidePadding*2 + bodyWidth, y: connectionHeight))
        } // Path
    } // func path(in rect: CGRect) -> Path
    
    private func calculateBodyHeight() -> CGFloat {
        var height: CGFloat = connectionHeight + extensionTopPadding
        
        // conform
        if 0 < holder.conformingProtocolNames.count {
            height += connectionHeight
            height += itemHeight*CGFloat(holder.conformingProtocolNames.count)
            height += bottomPaddingForLastText
        }
        
        // typealiases
        if 0 < holder.typealiases.count {
            height += connectionHeight
            height += itemHeight*CGFloat(holder.typealiases.count)
            height += bottomPaddingForLastText
        }
        
        // initializers
        if 0 < holder.initializers.count {
            height += connectionHeight
            height += itemHeight*CGFloat(holder.initializers.count)
            height += bottomPaddingForLastText
        }
        
        // property
        if 0 < holder.variables.count {
            height += connectionHeight
            height += itemHeight*CGFloat(holder.variables.count)
            height += bottomPaddingForLastText
        }
        
        // method
        if 0 < holder.functions.count {
            height += connectionHeight
            height += itemHeight*CGFloat(holder.functions.count)
            height += bottomPaddingForLastText
        }
        
        let nestedStructs = holder.nestingConvertedToStringStructHolders
        for nestedStruct in nestedStructs {
            height += headerItemHeight + nestTopPaddingWithConnectionHeight
            if 0 < nestedStruct.generics.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.generics.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedStruct.conformingProtocolNames.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.conformingProtocolNames.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedStruct.typealiases.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.typealiases.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedStruct.initializers.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.initializers.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedStruct.variables.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.variables.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedStruct.functions.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedStruct.functions.count)
                height += bottomPaddingForLastText
            }
            height += nestBottomPadding
        } // for nestedStruct in nestedStructs
        
        let nestedClasses = holder.nestingConvertedToStringClassHolders
        for nestedClass in nestedClasses {
            height += headerItemHeight + nestTopPaddingWithConnectionHeight
            if 0 < nestedClass.generics.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.generics.count)
                height += bottomPaddingForLastText
            }
            if let _ = nestedClass.superClassName {
                height += connectionHeight
                height += itemHeight
                height += bottomPaddingForLastText
            }
            if 0 < nestedClass.conformingProtocolNames.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.conformingProtocolNames.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedClass.typealiases.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.typealiases.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedClass.initializers.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.initializers.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedClass.variables.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.variables.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedClass.functions.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedClass.functions.count)
                height += bottomPaddingForLastText
            }
            height += nestBottomPadding
        } // for nestedClass in nestedClasses
        
        let nestedEnums = holder.nestingConvertedToStringEnumHolders
        for nestedEnum in nestedEnums {
            height += headerItemHeight + nestTopPaddingWithConnectionHeight
            if 0 < nestedEnum.generics.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.generics.count)
                height += bottomPaddingForLastText
            }
            if let _ = nestedEnum.rawvalueType {
                height += connectionHeight
                height += itemHeight
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.conformingProtocolNames.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.conformingProtocolNames.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.typealiases.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.typealiases.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.initializers.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.initializers.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.cases.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.cases.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.variables.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.variables.count)
                height += bottomPaddingForLastText
            }
            if 0 < nestedEnum.functions.count {
                height += connectionHeight
                height += itemHeight*CGFloat(nestedEnum.functions.count)
                height += bottomPaddingForLastText
            }
            height += nestBottomPadding
        } // for nestedEnum in nestedEnums

        return height
    } // func calculateFrameHeight() -> CGFloat
} // struct ExtensionFrame

//struct ExtensionFrame_Previews: PreviewProvider {
//    static var previews: some View {
//        ExtensionFrame()
//    }
//}
