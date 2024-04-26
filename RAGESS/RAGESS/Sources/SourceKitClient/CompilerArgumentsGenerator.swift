//
//  CompilerArgumentsGenerator.swift
//
//
//  Created by ockey12 on 2024/04/27.
//

import Foundation

struct CompilerArgumentsGenerator {
    let derivedDataPath: String
    var moduleName: String
    let sourceFilePaths: [String]

    var arguments: [String] {
        [
            "-vfsoverlay",
            derivedDataPath + "/Index.noindex/Build/Intermediates.noindex/index-overlay.yaml",
            "-module-name",
            moduleName,
            "-Onone",
            "-enforce-exclusivity=checked"
        ]
            + sourceFilePaths
            + [
                "-DSWIFT_PACKAGE",
                "-DDEBUG"
            ]
            + getModuleMapPaths(derivedDataPath: derivedDataPath)
        + [
            "-DXcode",
            "-sdk",
            // TODO: Make ↓ dynamically generated
            "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk",
            "-target",
            "arm64-apple-macos14.0",
            "-g",
            "-module-cache-path",
            moduleCachePath,
            "-Xfrontend",
            "-serialize-debugging-options",
            "-enable-testing",
            "-swift-version",
            "5",
            "-I",
            debugPath,
            "-I",
            // TODO: Make ↓ dynamically generated
            "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib",
            "-F",
            packageFrameworksPath,
            "-F",
            debugPath,
            "-F",
            // TODO: Make ↓ dynamically generated
            "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks",
        ]
    }

    var moduleCachePath: String {
        var path = NSString(string: derivedDataPath).deletingPathExtension
        return path + "/ModuleCache.noindex"
    }

    var debugPath: String {
        derivedDataPath + "/Index.noindex/Build/Products/Debug"
    }

    var packageFrameworksPath: String {
        derivedDataPath + "/Index.noindex/Build/Products/Debug/PackageFrameworks"
    }

    func getModuleMapPaths(derivedDataPath: String) -> [String] {
        let fileManager = FileManager.default
        let path = derivedDataPath + "/Index.noindex/Build/Intermediates.noindex/GeneratedModuleMaps/"
        let url = URL(fileURLWithPath: path)

        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) else {
            return []
        }

        var moduleMapPaths: [String] = []

        while let fileURL = enumerator.nextObject() as? URL {
            if fileURL.pathExtension == "modulemap" {
                moduleMapPaths.append("-Xcc")
                moduleMapPaths.append(fileURL.path)
            }
        }

        return moduleMapPaths
    }
}
