// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RAGESS",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "FileTreeView",
            targets: ["FileTreeView"]
        ),
        .library(
            name: "DebugView",
            targets: ["DebugView"]
        ),
        .library(
            name: "RAGESSView",
            targets: ["RAGESSView"]
        ),
        .library(
            name: "SwiftDiagramView",
            targets: ["SwiftDiagramView"]
        ),
        .library(
            name: "SwiftDiagramView",
            targets: [
                "SwiftDiagramView",
                "TypeDeclaration"
            ]
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
            from: "1.15.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/jpsim/SourceKitten.git",
            .upToNextMinor(from: "0.34.1")
        ),
        .package(
            url: "https://github.com/kateinoigakukun/swift-indexstore.git",
            .upToNextMinor(from: "0.3.0")
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
                "DumpPackageClient",
                "DependenciesClient",
                "MonitorClient",
                "LSPClient",
                "SourceFileClient",
                "SourceKitClient",
                "SwiftIndexStoreClient",
                "TypeAnnotationClient",
                "TypeDeclaration",
                "DeclarationExtractor",
                "XcodeObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DeclarationExtractor",
            dependencies: [
                "DeclaredObject",
                "SourceKitClient",
                "TypeDeclaration",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        ),
        .target(
            name: "DeclarationObjectsClient",
            dependencies: [
                "TypeDeclaration",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "DeclaredObject",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "DependenciesClient",
            dependencies: [
                "SourceKitClient",
                "TypeDeclaration",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
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
            name: "FileTreeView",
            dependencies: [
                "DeclarationObjectsClient",
                "TypeDeclaration",
                "XcodeObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies")
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
            name: "MonitorClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "RAGESSView",
            dependencies: [
                "BuildSettingsClient",
                "DebugView",
                "DeclarationExtractor",
                "DeclarationObjectsClient",
                "DependenciesClient",
                "DumpPackageClient",
                "FileTreeView",
                "MonitorClient",
                "SourceFileClient",
                "SwiftDiagramView",
                "XcodeObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(name: "Sample"),
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
            name: "SwiftDiagramView",
            dependencies: [
                "DeclarationObjectsClient",
                "TypeDeclaration",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "SwiftIndexStoreClient",
            dependencies: [
                "DeclaredObject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftIndexStore", package: "swift-indexstore")
            ]
        ),
        .target(
            name: "TypeAnnotationClient",
            dependencies: [
                "LSPClient",
                "SourceFileClient",
                "XcodeObject",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "TypeDeclaration",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LSPBindings", package: "sourcekit-lsp")
            ]
        ),
        .target(
            name: "XcodeObject",
            dependencies: ["DeclaredObject"]
        ),
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
            name: "SwiftDiagramViewTests",
            dependencies: [
                "SwiftDiagramView",
                "TypeDeclaration",
                .product(name: "Dependencies", package: "swift-dependencies")
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
