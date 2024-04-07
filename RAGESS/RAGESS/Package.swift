// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RAGESS",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Greeting",
            targets: ["Greeting"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Greeting",
            dependencies: []
        ),
        .testTarget(
            name: "Sample",
            dependencies: []
        )
    ]
)
