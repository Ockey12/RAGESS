// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RAGESS",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "DebugView",
            targets: ["DebugView"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/sourcekit-lsp",
            branch: "release/5.10"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMinor(from: "1.9.2")
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            .upToNextMinor(from: "1.2.2")
        )
    ],
    targets: [
        .target(
            name: "DebugView",
            dependencies: [
                "LSPClient",
                "SourceCodeClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DependenciesClient",
            dependencies: []
        ),
        .target(
            name: "LSPClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "SourceCodeClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "Sample",
            dependencies: []
        )
    ]
)
