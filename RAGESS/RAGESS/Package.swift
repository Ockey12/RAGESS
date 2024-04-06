// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RAGESS",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "RAGESS",
            targets: ["ContentView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Client",
            dependencies: []
        ),
        .target(
            name: "ContentView",
            dependencies: []
        ),
        .testTarget(
            name: "ClientTests",
            dependencies: []
        )
    ]
)
