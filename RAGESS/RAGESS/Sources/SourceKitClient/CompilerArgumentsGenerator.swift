//
//  CompilerArgumentsGenerator.swift
//
//
//  Created by ockey12 on 2024/04/27.
//

import Foundation

public struct CompilerArgumentsGenerator {
    public init(
        derivedDataPath: String,
        xcodeprojPath: String,
        moduleName: String,
        sourceFilePaths: [String]
    ) {
        self.derivedDataPath = derivedDataPath
        self.xcodeprojPath = xcodeprojPath
        self.moduleName = moduleName
        self.sourceFilePaths = sourceFilePaths
    }

    let derivedDataPath: String
    let xcodeprojPath: String
    var moduleName: String
    let sourceFilePaths: [String]

    public var arguments: [String] {
        let path = [
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
                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks"
            ]
            + getExecutableMacroPaths(derivedDataPath: derivedDataPath)

        return path
            + [
                "-Xfrontend",
                "-experimental-allow-module-with-compiler-errors",
                "-Xfrontend",
                "-empty-abi-descriptor",
                "-Xcc",
                "-fretain-comments-from-system-headers",
                "-Xcc",
                "-Xclang",
                "-Xcc",
                "-detailed-preprocessing-record",
                "-Xcc",
                "-Xclang",
                "-Xcc",
                "-fmodule-format=raw",
                "-Xcc",
                "-ferror-limit=10",
                "-Xcc",
                "-Xclang",
                "-Xcc",
                "-fallow-pch-with-compiler-errors",
                "-Xcc",
                "-Xclang",
                "-Xcc",
                "-fallow-pcm-with-compiler-errors",
                "-Xcc",
                "-Wno-non-modular-include-in-framework-module",
                "-Xcc",
                "-Wno-incomplete-umbrella",
                "-Xcc",
                "-fmodules-validate-system-headers",
                "-Xfrontend",
                "-package-name",
                "-Xfrontend",
                // TODO: Make ↓ dynamically generated
                "ragess",
                "-Xcc",
                overridesHmapPath
            ]
            + getIncludePaths(
                in: NSString(string: derivedDataPath).appendingPathComponent("/SourcePackages/checkouts"),
                ignoredDirectories: ["swift-package-manager"]
            )
            + [
                "-Xcc",
                "-DSWIFT_PACKAGE",
                "-Xcc",
                "-DDEBUG=1",
                "-working-directory",
                // TODO: Make ↓ dynamically generated
                "/Users/onaga/RAGESS/RAGESS/RAGESS"
            ]
    }

    var moduleCachePath: String {
        let path = NSString(string: derivedDataPath).deletingLastPathComponent
        return path + "/ModuleCache.noindex"
    }

    var debugPath: String {
        derivedDataPath + "/Index.noindex/Build/Products/Debug"
    }

    var packageFrameworksPath: String {
        derivedDataPath + "/Index.noindex/Build/Products/Debug/PackageFrameworks"
    }

    var overridesHmapPath: String {
        "-I"
            + derivedDataPath
            + "/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/"
            + moduleName
            + ".build/swift-overrides.hmap"
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
                moduleMapPaths.append("-fmodule-map-file=\(fileURL.path)")
            }
        }

        return moduleMapPaths
    }

    func getExecutableMacroPaths(derivedDataPath: String) -> [String] {
        let fileManager = FileManager.default
        let directoryPath = derivedDataPath + "/Index.noindex/Build/Products/Debug/"
        let url = URL(fileURLWithPath: directoryPath)

        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) else {
            return []
        }

        var macroPaths: [String] = []

        while let fileURL = enumerator.nextObject() as? URL {
            let path = fileURL.path

            guard let attributes = try? fileManager.attributesOfItem(atPath: path) else {
                continue
            }

            let fileType = attributes[.type] as? FileAttributeType
            let filePermissions = attributes[.posixPermissions] as? Int

            if fileType == .typeRegular,
               isExecutable(filePermissions) {
                let fileName = fileURL.lastPathComponent
                macroPaths.append("-Xfrontend")
                macroPaths.append("-load-plugin-executable")
                macroPaths.append("-Xfrontend")
                macroPaths.append("\(directoryPath)\(fileName)#\(fileName)")
            }
        }

        return macroPaths

        func isExecutable(_ permissions: Int?) -> Bool {
            guard let permissions = permissions else {
                return false
            }

            let executableMask = 0o111
            return permissions & executableMask != 0
        }
    }

    func getBuildDirectoryPaths(in directory: String) -> [String] {
        let fileManager = FileManager.default
        var buildDirectories: [String] = []

        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            return buildDirectories
        }

        while let path = enumerator.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(path)
            var isDirectory: ObjCBool = false

            fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                if (path as NSString).lastPathComponent == ".build" {
                    buildDirectories.append(fullPath)
                } else {
                    buildDirectories.append(contentsOf: getBuildDirectoryPaths(in: fullPath))
                }
            }
        }

        return buildDirectories
    }

    public func getIncludePaths(in directory: String, ignoredDirectories: [String]) -> [String] {
        var includePaths: [String] = []
        let fileManager = FileManager.default
        guard let paths = try? fileManager.contentsOfDirectory(atPath: directory) else {
            return []
        }

        let ignoredDirectoriesSet = Set(ignoredDirectories)
        var isDirectory: ObjCBool = false

        for path in paths {
            let fullPath = NSString(string: directory).appendingPathComponent(path)
            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                continue
            }
            let directoryName = NSString(string: path).lastPathComponent
            guard !ignoredDirectoriesSet.contains(directoryName) else {
                continue
            }
            if path == "include" {
                includePaths.append("-Xcc")
                includePaths.append("-I\(fullPath)")
            } else {
                includePaths.append(contentsOf: getIncludePaths(in: fullPath, ignoredDirectories: ignoredDirectories))
            }
        }

        return includePaths
    }
}
