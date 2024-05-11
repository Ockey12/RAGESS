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
        ),
        .package(
            url: "https://github.com/jpsim/SourceKitten.git",
            .upToNextMinor(from: "0.34.1")
        )
    ],
    targets: [
        .target(
            name: "BuildSettingsClient",
            dependencies: [
                "CommandClient",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "CommandClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "DebugView",
            dependencies: [
                "BuildSettingsClient",
                "TypeDeclaration",
                "DumpPackageClient",
                "LSPClient",
                "SourceFileClient",
                "SourceKitClient",
                "TypeAnnotationClient",
                "TypeDeclarationExtractor",
                "XcodeObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DependenciesClient",
            dependencies: [
                "Dependency",
                "TypeDeclaration",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Dependency",
            dependencies: [
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "DumpPackageClient",
            dependencies: [
                "CommandClient",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "LSPClient",
            dependencies: [
                "SourceFileClient",
                "XcodeObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "SourceFileClient",
            dependencies: [
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "SourceKitClient",
            dependencies: [
                "LSPClient",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp"),
                .product(name: "SourceKittenFramework", package: "SourceKitten")
            ]
        ),
        .target(
            name: "TypeAnnotationClient",
            dependencies: [
                "LSPClient",
                "SourceFileClient",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "TypeDeclaration",
            dependencies: [
                "Dependency",
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "TypeDeclarationExtractor",
            dependencies: [
                "TypeDeclaration",
                "XcodeObject",
                .product(name: "LSPBindings", package: "sourcekit-lsp"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        ),
        .target(name: "XcodeObject"),
        .testTarget(
            name: "LSPClientTests",
            dependencies: [
                "LSPClient",
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .testTarget(
            name: "SourceKitClientTests",
            dependencies: [
                "LSPClient",
                "SourceKitClient",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp"),
                .product(name: "SourceKittenFramework", package: "SourceKitten")
            ]
        ),
        .testTarget(
            name: "TypeAnnotationClientTests",
            dependencies: [
                "TypeAnnotationClient",
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        )
    ]
)
