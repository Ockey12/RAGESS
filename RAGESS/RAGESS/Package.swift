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
            url: "https://github.com/apple/swift-syntax.git",
            .upToNextMinor(from: "510.0.1")
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
                "SourceFileClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DeclarationType",
            dependencies: [
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "DependenciesClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "LSPClient",
            dependencies: [
                "SourceFileClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "SourceFileClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "TypeAnnotationClient",
            dependencies: [
                "LSPClient",
                "SourceFileClient",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .testTarget(
            name: "Sample",
            dependencies: []
        )
    ]
)
