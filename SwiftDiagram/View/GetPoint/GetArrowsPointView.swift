//
//  GetArrowsPointView.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/12/28.
//

import SwiftUI

struct GetArrowsPointView: View {
    @EnvironmentObject var monitor: BuildFileMonitor
    @EnvironmentObject var arrowPoint: ArrowPoint
    @EnvironmentObject var maxWidthHolder: MaxWidthHolder
    
    @EnvironmentObject var canDrawArrowFlag: CanDrawArrowFlag
    
    @EnvironmentObject var redrawCounter: RedrawCounter
    
    @State private var maxWidth: Double = ComponentSettingValues.minWidth
    private let allStringOfHolder = AllStringOfHolder()
    
    let textTrailPadding = ComponentSettingValues.textTrailPadding
    let arrowTerminalWidth = ComponentSettingValues.arrowTerminalWidth
    let extensionOutsidePadding = ComponentSettingValues.extensionOutsidePadding
    let connectionHeight = ComponentSettingValues.connectionHeight
    let itemHeight = ComponentSettingValues.itemHeight
    let bottomPaddingForLastText = ComponentSettingValues.bottomPaddingForLastText
    let nestTopPaddingWithConnectionHeight = ComponentSettingValues.nestTopPaddingWithConnectionHeight
    let nestBottomPadding = ComponentSettingValues.nestBottomPadding
    
    var body: some View {
        ZStack {
            Text("")
                .onChange(of: arrowPoint.changeDate) { _ in
                    DispatchQueue.main.async {
                        
                        // MARK: - Protocol
                        arrowPoint.initialize()
                        for protocolHolder in monitor.getProtocol() {
                            let name = protocolHolder.name
                            guard let width = maxWidthHolder.maxWidthDict[name]?.maxWidth else {
                                continue
                            }
                            var currentPoint = arrowPoint.getStartPoint()

                            // Header Component
                            getPointOfHeader(holderName: name,
                                             numberOfExtension: protocolHolder.extensions.count,
                                             currentPoint: &currentPoint)
                            
                            // Conform Component
                            getPointOfComponent(holderName: name,
                                                elementNames: protocolHolder.conformingProtocolNames,
                                                componentKind: .conform,
                                                currentPoint: &currentPoint)
                            
                            // Associated Type Component
                            getPointOfAssociatedType(numberOfAssociatedType: protocolHolder.associatedTypes.count,
                                                     currentPoint: &currentPoint)

                            // Typealias Component
                            getPointOfComponent(holderName: name,
                                                elementNames: protocolHolder.typealiases,
                                                componentKind: .typealias,
                                                currentPoint: &currentPoint)
                            
                            // Property Component
                            getPointOfComponent(holderName: name,
                                                elementNames: protocolHolder.variables,
                                                componentKind: .property,
                                                currentPoint: &currentPoint)
                            
                            // Initializer Component
                            getPointOfComponent(holderName: name,
                                                elementNames: protocolHolder.initializers,
                                                componentKind: .initializer,
                                                currentPoint: &currentPoint)
                            
                            // Method Component
                            getPointOfComponent(holderName: name,
                                                elementNames: protocolHolder.functions,
                                                componentKind: .method,
                                                currentPoint: &currentPoint)
                            
                            // Extension Component
                            getPointOfExtension(holderName: name,
                                                extensionHolders: protocolHolder.extensions,
                                                currentPoint: &currentPoint)
                            
                            // 右隣の型に移動する
                            arrowPoint.moveToNextType(currentPoint: currentPoint,
                                                      width: width,
                                                      numberOfExtensin: protocolHolder.extensions.count)
                        } // for protocolHolder in monitor.getProtocol()
                        
                        // MARK: - Struct
                        arrowPoint.moveToDownerHStack(typeKind: .struct)
                        for structHolder in monitor.getStruct() {
                            let name = structHolder.name
                            guard let width = maxWidthHolder.maxWidthDict[name]?.maxWidth else {
                                continue
                            }
                            var currentPoint = arrowPoint.getStartPoint()
                            
                            // Header Component
                            getPointOfHeader(holderName: name,
                                             numberOfExtension: structHolder.extensions.count,
                                             currentPoint: &currentPoint)
                            
                            // Generic Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.generics,
                                                componentKind: .generic,
                                                currentPoint: &currentPoint)

                            // Conform Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.conformingProtocolNames,
                                                componentKind: .conform,
                                                currentPoint: &currentPoint)

                            // Typealias Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.typealiases,
                                                componentKind: .typealias,
                                                currentPoint: &currentPoint)

                            // Property Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.variables,
                                                componentKind: .property,
                                                currentPoint: &currentPoint)

                            // Initializer Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.initializers,
                                                componentKind: .initializer,
                                                currentPoint: &currentPoint)
                            
                            // Method Component
                            getPointOfComponent(holderName: name,
                                                elementNames: structHolder.functions,
                                                componentKind: .method,
                                                currentPoint: &currentPoint)

                            // Nested Struct
                            skipNestedStruct(nestedStructs: structHolder.nestingConvertedToStringStructHolders,
                                             currentPoint: &currentPoint)
                            
                            // Nested Class
                            skipNestedClass(nestedClasses: structHolder.nestingConvertedToStringClassHolders,
                                            currentPoint: &currentPoint)
                            
                            // Nested Enum
                            skipNestedEnum(nestedEnums: structHolder.nestingConvertedToStringEnumHolders,
                                           currentPoint: &currentPoint)
                            
                            // Extension Component
                            getPointOfExtension(holderName: name,
                                                extensionHolders: structHolder.extensions,
                                                currentPoint: &currentPoint)
                            
                            // 右隣の型に移動する
                            arrowPoint.moveToNextType(currentPoint: currentPoint,
                                                      width: width,
                                                      numberOfExtensin: structHolder.extensions.count)
                        } // for structHolder in monitor.getStruct()
                        
                        // MARK: - Class
                        arrowPoint.moveToDownerHStack(typeKind: .class)
                        for classHolder in monitor.getClass() {
                            let name = classHolder.name
                            guard let width = maxWidthHolder.maxWidthDict[name]?.maxWidth else {
                                continue
                            }
                            var currentPoint = arrowPoint.getStartPoint()
                            
                            // Header Component
                            getPointOfHeader(holderName: name,
                                             numberOfExtension: classHolder.extensions.count,
                                             currentPoint: &currentPoint)
                            
                            // Generic Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.generics,
                                                componentKind: .generic,
                                                currentPoint: &currentPoint)
                            
                            // Super Class Component
                            if let superClass = classHolder.superClassName {
                                getPointOfComponent(holderName: name,
                                                    elementNames: [superClass],
                                                    componentKind: .superClass,
                                                    currentPoint: &currentPoint)
                            }
                            
                            // Conform Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.conformingProtocolNames,
                                                componentKind: .conform,
                                                currentPoint: &currentPoint)
                            
                            // Typealias Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.typealiases,
                                                componentKind: .typealias,
                                                currentPoint: &currentPoint)

                            // Property Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.variables,
                                                componentKind: .property,
                                                currentPoint: &currentPoint)

                            // Initializer Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.initializers,
                                                componentKind: .initializer,
                                                currentPoint: &currentPoint)
                            
                            // Method Component
                            getPointOfComponent(holderName: name,
                                                elementNames: classHolder.functions,
                                                componentKind: .method,
                                                currentPoint: &currentPoint)
                            
                            // Nested Struct
                            skipNestedStruct(nestedStructs: classHolder.nestingConvertedToStringStructHolders,
                                             currentPoint: &currentPoint)
                            
                            // Nested Class
                            skipNestedClass(nestedClasses: classHolder.nestingConvertedToStringClassHolders,
                                            currentPoint: &currentPoint)
                            
                            // Nested Enum
                            skipNestedEnum(nestedEnums: classHolder.nestingConvertedToStringEnumHolders,
                                           currentPoint: &currentPoint)
                            
                            // Extension Component
                            getPointOfExtension(holderName: name,
                                                extensionHolders: classHolder.extensions,
                                                currentPoint: &currentPoint)
                            
                            // 右隣の型に移動する
                            arrowPoint.moveToNextType(currentPoint: currentPoint,
                                                      width: width,
                                                      numberOfExtensin: classHolder.extensions.count)
                        } // for classHolder in monitor.getClass()
                        
                        // MARK: - Enum
                        arrowPoint.moveToDownerHStack(typeKind: .enum)
                        for enumHolder in monitor.getEnum() {
                            let name = enumHolder.name
                            guard let width = maxWidthHolder.maxWidthDict[name]?.maxWidth else {
                                continue
                            }
                            var currentPoint = arrowPoint.getStartPoint()
                            
                            // Header Component
                            getPointOfHeader(holderName: name,
                                             numberOfExtension: enumHolder.extensions.count,
                                             currentPoint: &currentPoint)
                            
                            // Generic Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.generics,
                                                componentKind: .generic,
                                                currentPoint: &currentPoint)
                            
                            // Rawvalue Type Component
                            if let rawvalue = enumHolder.rawvalueType {
                                getPointOfComponent(holderName: name,
                                                    elementNames: [rawvalue],
                                                    componentKind: .rawvalueType,
                                                    currentPoint: &currentPoint)
                            }
                            
                            // Conform Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.conformingProtocolNames,
                                                componentKind: .conform,
                                                currentPoint: &currentPoint)
                            
                            // Typealias Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.typealiases,
                                                componentKind: .typealias,
                                                currentPoint: &currentPoint)

                            // Case Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.cases,
                                                componentKind: .case,
                                                currentPoint: &currentPoint)

                            // Property Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.variables,
                                                componentKind: .property,
                                                currentPoint: &currentPoint)

                            // Initializer Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.initializers,
                                                componentKind: .initializer,
                                                currentPoint: &currentPoint)
                            
                            // Method Component
                            getPointOfComponent(holderName: name,
                                                elementNames: enumHolder.functions,
                                                componentKind: .method,
                                                currentPoint: &currentPoint)
                            
                            // Nested Struct
                            skipNestedStruct(nestedStructs: enumHolder.nestingConvertedToStringStructHolders,
                                             currentPoint: &currentPoint)
                            
                            // Nested Class
                            skipNestedClass(nestedClasses: enumHolder.nestingConvertedToStringClassHolders,
                                            currentPoint: &currentPoint)
                            
                            // Nested Enum
                            skipNestedEnum(nestedEnums: enumHolder.nestingConvertedToStringEnumHolders,
                                           currentPoint: &currentPoint)
                            
                            // Extension Component
                            getPointOfExtension(holderName: name,
                                                extensionHolders: enumHolder.extensions,
                                                currentPoint: &currentPoint)
                            
                            // 右隣の型に移動する
                            arrowPoint.moveToNextType(currentPoint: currentPoint,
                                                      width: width,
                                                      numberOfExtensin: enumHolder.extensions.count)
                        } // for enumHolder in monitor.getEnum()
                        
//                        ForEach(arrowPoint.points, id: \.self) { point in
//                            if let start = point.start,
//                               let end = point.end {
//                                ArrowView(start: start, end: end)
////                                    .opacity(arrowOpacity)
//                            }
//                        }
                        canDrawArrowFlag.flag = true
                    } // DispatchQueue.main.async
                } // .onChange(of: monitor.getChangeDate())
        } // ZStack
        .onChange(of: monitor.getChangeDate()) { _ in
            // 座標を保持している配列を空にする
            arrowPoint.points.removeAll()
            
            // 依存関係を取得する
            let dependences = monitor.getDependence()
            for dependence in dependences {
                // 影響を与える側の名前
                let affectingTypeName = dependence.affectingTypeName
                
                for affectedType in dependence.affectedTypes {
                    // 影響を受ける側の名前
                    let affecteder = affectedType.affectedTypeName
                    let componentKind = affectedType.componentKind
                    let numOfComponent = affectedType.numberOfComponent
                    
                    // Pointインスタンスに、影響を与える側と影響を受ける側の名前だけを登録する
                    var point = ArrowPoint.Point(affecterName: affectingTypeName,
                                                 affectedName: affecteder,
                                                 affectedComponentKind: componentKind,
                                                 numberOfAffectedComponent: numOfComponent)
                    if let numOfExtension = affectedType.numberOfExtension {
                        // extension内で宣言されている要素のとき
                        point.numberOfAffectedExtension = numOfExtension
                    }
                    arrowPoint.points.append(point)
                } // for affectedType in dependence.affectedTypes
            } // for dependence in dependences
            
            // debug
            print("============ GetArrowsPointView.onChange =============")
            for point in arrowPoint.points {
                print("affecter: " + point.affecterName)
                print("affecteder: " + point.affectedName)
                print("-------------------------")
            }
        } // onAppear
    } // var body
    
    private func getPointOfHeader(holderName: String, numberOfExtension: Int, currentPoint: inout CGPoint) {
        guard let width = maxWidthHolder.maxWidthDict[holderName]?.maxWidth else {
            return
        }
        if 0 < numberOfExtension {
            // extensionが宣言されていたら、extensionコンポーネントの幅を考慮する
            currentPoint.x += extensionOutsidePadding - arrowTerminalWidth
        }
        
        // MARK: - Header Component
        for (index, point) in arrowPoint.points.enumerated() {
            if point.affecterName == holderName {
                // このプロトコルが影響を与える側のとき
                let startRightX = currentPoint.x + width + textTrailPadding + arrowTerminalWidth*2
                arrowPoint.points[index].startLeft = currentPoint
                arrowPoint.points[index].startRight = CGPoint(x: startRightX, y: currentPoint.y)
//                print("startRightX: \(startRightX)")
            }
        } // for (index, point) in arrowPoint.points.enumerated()
        currentPoint.y += itemHeight/2
        currentPoint.y += bottomPaddingForLastText
        currentPoint.y += connectionHeight
    }
    
    private func getPointOfComponent(holderName: String, elementNames: [String], componentKind: DetailComponentView.ComponentKind, currentPoint: inout CGPoint) {
        guard let width = maxWidthHolder.maxWidthDict[holderName]?.maxWidth else {
            return
        }
        if 0 < elementNames.count {
            currentPoint.y += itemHeight/2
        }
        for num in 0..<elementNames.count {
            for (index, point) in arrowPoint.points.enumerated() {
                if (point.affectedName == holderName) &&
                    (point.affectedComponentKind == componentKind) &&
                    (point.numberOfAffectedComponent == num) {
                    let startRightX = currentPoint.x + width + textTrailPadding + arrowTerminalWidth*2
                    arrowPoint.points[index].endLeft = currentPoint
                    arrowPoint.points[index].endRight = CGPoint(x: startRightX, y: currentPoint.y)
                }
            } // for (index, point) in arrowPoint.points.enumerated()
            if num != elementNames.count - 1 {
                currentPoint.y += itemHeight
            }
        } // for num in 0..<elementNames.count
        if 0 < elementNames.count {
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
        }
    } // func getPointOfComponent(holderName: String, elementNames: [String], componentKind: DetailComponentView.ComponentKind, currentPoint: inout CGPoint)
    
    private func getPointOfAssociatedType(numberOfAssociatedType: Int, currentPoint: inout CGPoint) {
        // associatedtypeは新しく名前を宣言するだけで、他の型に依存しない
        if 0 < numberOfAssociatedType {
            currentPoint.y += itemHeight/2
        }
        for num in 0..<numberOfAssociatedType {
            if num != numberOfAssociatedType - 1 {
                currentPoint.y += itemHeight
            }
        }
        if 0 < numberOfAssociatedType {
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
        }
    } // func getPointOfAssociatedType(numberOfAssociatedType: Int, currentPoint: inout CGPoint)
    
    private func skipNestedStruct(nestedStructs: [ConvertedToStringStructHolder], currentPoint: inout CGPoint) {
        for nestedStruct in nestedStructs {
            currentPoint.y += nestTopPaddingWithConnectionHeight
            currentPoint.y += itemHeight/2
            skipComponent(elements: nestedStruct.generics, currentPoint: &currentPoint)
            skipComponent(elements: nestedStruct.conformingProtocolNames, currentPoint: &currentPoint)
            skipComponent(elements: nestedStruct.typealiases, currentPoint: &currentPoint)
            skipComponent(elements: nestedStruct.initializers, currentPoint: &currentPoint)
            skipComponent(elements: nestedStruct.variables, currentPoint: &currentPoint)
            skipComponent(elements: nestedStruct.functions, currentPoint: &currentPoint)
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
            currentPoint.y += nestBottomPadding
        }
    } // func skipNestedStruct(nestedStruct: ConvertedToStringStructHolder, currentPoint: inout CGPoint)
    
    private func skipNestedClass(nestedClasses: [ConvertedToStringClassHolder], currentPoint: inout CGPoint) {
        for nestedClass in nestedClasses {
            currentPoint.y += nestTopPaddingWithConnectionHeight
            currentPoint.y += itemHeight/2
            skipComponent(elements: nestedClass.generics, currentPoint: &currentPoint)
            if let superClass = nestedClass.superClassName {
                skipComponent(elements: [superClass], currentPoint: &currentPoint)
            }
            skipComponent(elements: nestedClass.conformingProtocolNames, currentPoint: &currentPoint)
            skipComponent(elements: nestedClass.typealiases, currentPoint: &currentPoint)
            skipComponent(elements: nestedClass.initializers, currentPoint: &currentPoint)
            skipComponent(elements: nestedClass.variables, currentPoint: &currentPoint)
            skipComponent(elements: nestedClass.functions, currentPoint: &currentPoint)
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
            currentPoint.y += nestBottomPadding
        }
    } // func skipNestedClass(nestedClasses: [ConvertedToStringClassHolder], currentPoint: inout CGPoint)
    
    private func skipNestedEnum(nestedEnums: [ConvertedToStringEnumHolder], currentPoint: inout CGPoint) {
        for nestedEnum in nestedEnums {
            currentPoint.y += nestTopPaddingWithConnectionHeight
            currentPoint.y += itemHeight/2
            skipComponent(elements: nestedEnum.generics, currentPoint: &currentPoint)
            if let rawvalue = nestedEnum.rawvalueType {
                skipComponent(elements: [rawvalue], currentPoint: &currentPoint)
            }
            skipComponent(elements: nestedEnum.conformingProtocolNames, currentPoint: &currentPoint)
            skipComponent(elements: nestedEnum.typealiases, currentPoint: &currentPoint)
            skipComponent(elements: nestedEnum.initializers, currentPoint: &currentPoint)
            skipComponent(elements: nestedEnum.cases, currentPoint: &currentPoint)
            skipComponent(elements: nestedEnum.variables, currentPoint: &currentPoint)
            skipComponent(elements: nestedEnum.functions, currentPoint: &currentPoint)
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
            currentPoint.y += nestBottomPadding
        }
    } // func skipNestedEnum(nestedEnums: [ConvertedToStringEnumHolder], currentPoint: inout CGPoint)
    
    private func skipComponent(elements: [String], currentPoint: inout CGPoint) {
        if 0 < elements.count {
            currentPoint.y += itemHeight/2
        }
        for num in 0..<elements.count {
            if num != elements.count - 1 {
                currentPoint.y += itemHeight
            }
        }
        if 0 < elements.count {
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
        }
    } // func skipComponent(elements: [String])
    
    private func getPointOfExtension(holderName: String, extensionHolders: [ConvertedToStringExtensionHolder], currentPoint: inout CGPoint) {
        guard let width = maxWidthHolder.maxWidthDict[holderName]?.maxWidth else {
            return
        }
        for numOfExtension in 0..<extensionHolders.count {
            guard let extensionWidth = maxWidthHolder.maxWidthDict[holderName]?.extensionWidth[numOfExtension] else {
                continue
            }
            let extensionX = currentPoint.x + (width - extensionWidth)/2
            let extensionHolder = extensionHolders[numOfExtension]
            currentPoint.y += connectionHeight*2
            
            // Conform Component
            getPointOfComponent(elements: extensionHolder.conformingProtocolNames,
                                numOfExtension: numOfExtension,
                                extensionX: extensionX,
                                extensionWidth: extensionWidth,
                                componentKind: .conform)
            
            // Typealias Component
            getPointOfComponent(elements: extensionHolder.typealiases,
                                numOfExtension: numOfExtension,
                                extensionX: extensionX,
                                extensionWidth: extensionWidth,
                                componentKind: .typealias)
            
            // Initializer Component
            getPointOfComponent(elements: extensionHolder.initializers,
                                numOfExtension: numOfExtension,
                                extensionX: extensionX,
                                extensionWidth: extensionWidth,
                                componentKind: .initializer)
            
            // Property Component
            getPointOfComponent(elements: extensionHolder.variables,
                                numOfExtension: numOfExtension,
                                extensionX: extensionX,
                                extensionWidth: extensionWidth,
                                componentKind: .property)
            
            // Method Component
            getPointOfComponent(elements: extensionHolder.functions,
                                numOfExtension: numOfExtension,
                                extensionX: extensionX,
                                extensionWidth: extensionWidth,
                                componentKind: .method)
            
            // Nested Struct
            skipNestedStruct(nestedStructs: extensionHolder.nestingConvertedToStringStructHolders,
                             currentPoint: &currentPoint)
            
            // Nested Class
            skipNestedClass(nestedClasses: extensionHolder.nestingConvertedToStringClassHolders,
                            currentPoint: &currentPoint)
            
            // Nested Enum
            skipNestedEnum(nestedEnums: extensionHolder.nestingConvertedToStringEnumHolders,
                           currentPoint: &currentPoint)
        } // for numOfExtension in 0..<extensionHolders.count
        if 0 < extensionHolders.count {
            currentPoint.y += itemHeight/2
            currentPoint.y += bottomPaddingForLastText
            currentPoint.y += connectionHeight
        }
        
        func getPointOfComponent(elements: [String], numOfExtension: Int, extensionX: Double, extensionWidth: Double, componentKind: DetailComponentView.ComponentKind) {
            if 0 < elements.count {
                currentPoint.y += itemHeight/2
            }
            for num in 0..<elements.count {
                for (index, point) in arrowPoint.points.enumerated() {
                    if (point.affectedName == holderName) &&
                        (point.numberOfAffectedExtension == numOfExtension) &&
                        (point.affectedComponentKind == componentKind) &&
                        (point.numberOfAffectedComponent == num) {
                        let startRightX = extensionX + extensionWidth + textTrailPadding + arrowTerminalWidth*2
                        arrowPoint.points[index].endLeft = CGPoint(x: extensionX, y: currentPoint.y)
                        arrowPoint.points[index].endRight = CGPoint(x: startRightX, y: currentPoint.y)
                    }
                } // for (index, point) in arrowPoint.points.enumerated()
                if num != elements.count - 1 {
                    currentPoint.y += itemHeight
                }
            } // for num in 0..<elements.count
            if 0 < elements.count {
                currentPoint.y += itemHeight/2
                currentPoint.y += bottomPaddingForLastText
                currentPoint.y += connectionHeight
            }
        } // func getPointOfComponent(elements: [String], numOfExtension: Int, extensionX: Double, extensionWidth: Double)
    } // func getPointOfExtension(holderName: String, extensionHolders: [ConvertedToStringExtensionHolder], currentPoint: inout CGPoint)
} // struct GetArrowsPointView

//struct GetArrowsPointView_Previews: PreviewProvider {
//    static var previews: some View {
//        GetArrowsPointView()
//    }
//}
