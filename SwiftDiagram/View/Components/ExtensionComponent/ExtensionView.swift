//
//  ExtensionView.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/16.
//

import SwiftUI

struct ExtensionView: View {
    let superHolderName: String
    let numberOfExtension: Int
    let holder: ConvertedToStringExtensionHolder
    let outsideFrameWidth: CGFloat
    
    @EnvironmentObject var arrowPoint: ArrowPoint
    @EnvironmentObject var maxWidthHolder: MaxWidthHolder
    @EnvironmentObject var monitor: BuildFileMonitor
    @EnvironmentObject var redrawCounter: RedrawCounter

    let borderWidth = ComponentSettingValues.borderWidth
    let arrowTerminalWidth = ComponentSettingValues.arrowTerminalWidth
    let textTrailPadding = ComponentSettingValues.textTrailPadding
    
    let headerItemHeight = ComponentSettingValues.headerItemHeight
    
    let connectionHeight = ComponentSettingValues.connectionHeight
    let itemHeight = ComponentSettingValues.itemHeight
    let bottomPaddingForLastText = ComponentSettingValues.bottomPaddingForLastText
    
    let extensionOutsidePadding = ComponentSettingValues.extensionOutsidePadding
    let extensionTopPadding = ComponentSettingValues.extensionTopPadding
    let extensionBottomPadding = ComponentSettingValues.extensionBottomPadding
    
    let nestTopPaddingWithConnectionHeight = ComponentSettingValues.nestTopPaddingWithConnectionHeight
    let nestBottomPadding = ComponentSettingValues.nestBottomPadding
    
    let fontSize = ComponentSettingValues.fontSize
    
    var allStrings: [String] {
        let allStringOfHolder = AllStringOfHolder()
        return allStringOfHolder.ofExtension(holder)
    } // var allStrings
    
    var maxTextWidth: Double {
        let calculator = MaxTextWidthCalculator()
        var width = calculator.getMaxWidth(allStrings)
        if width < ComponentSettingValues.minWidth {
            width = ComponentSettingValues.minWidth
        }
        if redrawCounter.getCount() < (monitor.numerOfAllType() + arrowPoint.numberOfDependence())*10 {
            DispatchQueue.main.async {
                if let superHolderWidth = maxWidthHolder.maxWidthDict[superHolderName] {
                    maxWidthHolder.maxWidthDict[superHolderName]!.extensionWidth[numberOfExtension] = width
                    if superHolderWidth.maxWidth < width {
                        maxWidthHolder.maxWidthDict[superHolderName]!.maxWidth = width
                    }
                }
                let dt = Date()
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
                arrowPoint.changeDate = "\(dateFormatter.string(from: dt))"
                redrawCounter.increment()
            }
        }
        
        return width
    }
    
    var bodyWidth: Double {
        return maxTextWidth + textTrailPadding
    }
    
    var frameWidth: Double {
        return bodyWidth + arrowTerminalWidth*2 + CGFloat(4)
    }
    
    var outsideWidth: Double {
        return outsideFrameWidth + textTrailPadding
    }
    
    var body: some View {
        ZStack {
            ExtensionFrame(holder: holder, bodyWidth: outsideWidth)
                .frame(width: outsideWidth + extensionOutsidePadding*2 + CGFloat(4), height: calculateFrameHeight())
                .foregroundColor(.white)
            
            ExtensionFrame(holder: holder, bodyWidth: outsideWidth)
                .stroke(lineWidth: ComponentSettingValues.borderWidth)
                .fill(.black)
                .frame(width: outsideWidth + extensionOutsidePadding*2 + CGFloat(4), height: calculateFrameHeight())
            
            Text("Extension")
                .lineLimit(1)
                .font(.system(size: fontSize))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .position(x: outsideWidth/2 + extensionOutsidePadding, y: connectionHeight/2)
            
            VStack(spacing: 0) {
                // conform
                if 0 < holder.conformingProtocolNames.count {
                    DetailComponentView(componentType: .conform,
                                        strings: holder.conformingProtocolNames,
                                        bodyWidth: bodyWidth)
                    .frame(width: frameWidth,
                           height: calculateDetailComponentFrameHeight(numberOfItems: holder.conformingProtocolNames.count))
                }

                // typealiases
                if 0 < holder.typealiases.count {
                    DetailComponentView(componentType: .typealias,
                                        strings: holder.typealiases,
                                        bodyWidth: bodyWidth)
                    .frame(width: frameWidth,
                           height: calculateDetailComponentFrameHeight(numberOfItems: holder.typealiases.count))
                }

                // initializer
                if 0 < holder.initializers.count {
                    DetailComponentView(componentType: .initializer,
                                        strings: holder.initializers,
                                        bodyWidth: bodyWidth)
                    .frame(width: frameWidth,
                           height: calculateDetailComponentFrameHeight(numberOfItems: holder.initializers.count))
                }

                // property
                if 0 < holder.variables.count {
                    DetailComponentView(componentType: .property,
                                        strings: holder.variables,
                                        bodyWidth: bodyWidth)
                    .frame(width: frameWidth,
                           height: calculateDetailComponentFrameHeight(numberOfItems: holder.variables.count))
                }

                // method
                if 0 < holder.functions.count {
                    DetailComponentView(componentType: .method,
                                        strings: holder.functions,
                                        bodyWidth: bodyWidth)
                    .frame(width: frameWidth,
                           height: calculateDetailComponentFrameHeight(numberOfItems: holder.functions.count))
                }
                
                // nested Struct
                ForEach(holder.nestingConvertedToStringStructHolders, id: \.self) { nestedStruct in
                    NestStructView(holder: nestedStruct, outsideFrameWidth: maxTextWidth)
                        .frame(width: frameWidth)
                }
                
                // nested Class
                ForEach(holder.nestingConvertedToStringClassHolders, id: \.self) { nestedClass in
                    NestClassView(holder: nestedClass, outsideFrameWidth: maxTextWidth)
                        .frame(width: frameWidth)
                }
                
                // nested Enum
                ForEach(holder.nestingConvertedToStringEnumHolders, id: \.self) { nestedEnum in
                    NestEnumView(holder: nestedEnum, outsideFrameWidth: maxTextWidth)
                        .frame(width: frameWidth)
                }
            } // VStack
            .frame(height: calculateFrameHeight() - extensionTopPadding)
            .offset(y: connectionHeight)
            
        } // ZStack
    } // var body
    
    private func calculateFrameHeight() -> CGFloat {
        var height: CGFloat = extensionTopPadding
        
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
    
    private func calculateDetailComponentFrameHeight(numberOfItems: Int) -> CGFloat {
        var height = connectionHeight
        height += itemHeight*CGFloat(numberOfItems)
        height += bottomPaddingForLastText
        return height
    } // func calculateDetailComponentFrameHeight(numberOfItems: Int) -> CGFloat
} // struct ExtensionView

//struct ExtensionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExtensionView()
//    }
//}
