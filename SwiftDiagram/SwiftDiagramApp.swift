//
//  SwiftDiagramApp.swift
//  SwiftDiagram
//
//  Created by オナガ・ハルキ on 2022/11/14.
//

import SwiftUI

@main
struct SwiftDiagramApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BuildFileMonitor())
                .environmentObject(ArrowPoint())
                .environmentObject(MaxWidthHolder())
                .environmentObject(RedrawCounter())
                .environmentObject(CanDrawArrowFlag())
        }
    }
}
