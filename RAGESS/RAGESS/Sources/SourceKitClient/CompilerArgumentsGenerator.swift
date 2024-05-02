//
//  CompilerArgumentsGenerator.swift
//
//
//  Created by ockey12 on 2024/04/27.
//

import Dependencies
import Foundation
import TargetClient

public struct CompilerArgumentsGenerator {
    public init(
        targetFilePath: String,
        buildSettings: [String: String],
        xcodeprojPath: String,
        moduleName: String,
        sourceFilePaths: [String]
    ) {
        self.targetFilePath = targetFilePath
        self.buildSettings = buildSettings
        self.xcodeprojPath = xcodeprojPath
        self.moduleName = moduleName
        self.sourceFilePaths = sourceFilePaths
    }

    let targetFilePath: String
    let buildSettings: [String: String]
    let xcodeprojPath: String
    var moduleName: String
    let sourceFilePaths: [String]

    public func generateArguments() async throws -> [String] {
        guard let buildDirectory = buildSettings["BUILD_DIR"] else {
            throw CompilerArgumentGenerationError.notFoundBuildDirectory
        }

        let derivedDataPath = URL(filePath: buildDirectory)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path()

        var moduleCachePath: String {
            let path = NSString(string: derivedDataPath).deletingLastPathComponent
            return NSString(string: path).appendingPathComponent("/ModuleCache.noindex")
        }

        let packageFrameworksPath = NSString(string: derivedDataPath)
            .appendingPathComponent("/Index.noindex/Build/Products/Debug/PackageFrameworks")

        let debugPath = NSString(string: derivedDataPath)
            .appendingPathComponent("/Index.noindex/Build/Products/Debug")

        let overridesHmapPath = URL(fileURLWithPath: "-I")
            .appendingPathComponent(derivedDataPath)
            .appendingPathComponent("/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/")
            .appendingPathComponent("\(moduleName).build/swift-overrides.hmap")
            .path()

        var arguments = ["-vfsoverlay"]
        arguments.append(NSString(string: derivedDataPath).appendingPathComponent("/Index.noindex/Build/Intermediates.noindex/index-overlay.yaml"))
        arguments.append("-module-name")
        arguments.append(moduleName)
        arguments.append("-Onone")
        arguments.append("-enforce-exclusivity=checked")
        arguments.append(contentsOf: sourceFilePaths)
        arguments.append("-DSWIFT_PACKAGE")
        arguments.append("-DDEBUG")
        arguments.append(contentsOf: getModuleMapPaths(derivedDataPath: derivedDataPath))
        arguments.append("-DXcode")
        arguments.append("-sdk")

        guard let sdkPath = buildSettings["SDKROOT"] else {
            throw CompilerArgumentGenerationError.notFoundSDK
        }
        arguments.append(sdkPath)
        arguments.append("-target")

        @Dependency(TargetClient.self) var targetClient
        guard let target = try? await targetClient.getTarget() else {
            throw CompilerArgumentGenerationError.notFoundTarget
        }
        arguments.append(target)
        arguments.append("-g")
        arguments.append("-module-cache-path")
        arguments.append(moduleCachePath)
        arguments.append("-Xfrontend")
        arguments.append("-serialize-debugging-options")
        arguments.append("-enable-testing")
        arguments.append("-swift-version")

        guard let swiftVersion = buildSettings["SWIFT_VERSION"] else {
            throw CompilerArgumentGenerationError.notFoundSwiftVersion
        }
        arguments.append(swiftVersion)
        arguments.append("-I")
        arguments.append(debugPath)
        arguments.append("-I")

        guard let testLibraryPath = buildSettings["TEST_LIBRARY_SEARCH_PATHS"] else {
            throw CompilerArgumentGenerationError.notFoundTestLibraryPath
        }
        arguments.append(testLibraryPath)
        arguments.append("-F")
        arguments.append(packageFrameworksPath)
        arguments.append("-F")
        arguments.append(debugPath)
        arguments.append("-F")

        guard let testFrameworkPath = buildSettings["TEST_FRAMEWORK_SEARCH_PATHS"] else {
            throw CompilerArgumentGenerationError.notFoundTestFrameworkPath
        }
        arguments.append(testFrameworkPath)
        arguments.append(contentsOf: getExecutableMacroPaths(derivedDataPath: derivedDataPath))
        arguments.append("-Xfrontend")
        arguments.append("-experimental-allow-module-with-compiler-errors")
        arguments.append("-Xfrontend")
        arguments.append("-empty-abi-descriptor")
        arguments.append("-Xcc")
        arguments.append("-fretain-comments-from-system-headers")
        arguments.append("-Xcc")
        arguments.append("-Xclang")
        arguments.append("-Xcc")
        arguments.append("-detailed-preprocessing-record")
        arguments.append("-Xcc")
        arguments.append("-Xclang")
        arguments.append("-Xcc")
        arguments.append("-fmodule-format=raw")
        arguments.append("-Xcc")
        arguments.append("-ferror-limit=10")
        arguments.append("-Xcc")
        arguments.append("-Xclang")
        arguments.append("-Xcc")
        arguments.append("-fallow-pch-with-compiler-errors")
        arguments.append("-Xcc")
        arguments.append("-Xclang")
        arguments.append("-Xcc")
        arguments.append("-fallow-pcm-with-compiler-errors")
        arguments.append("-Xcc")
        arguments.append("-Wno-non-modular-include-in-framework-module")
        arguments.append("-Xcc")
        arguments.append("-Wno-incomplete-umbrella")
        arguments.append("-Xcc")
        arguments.append("-fmodules-validate-system-headers")

        if let packageName = getPackageName(sourceFilePath: targetFilePath) {
            arguments.append("-Xfrontend")
            arguments.append("-package-name")
            arguments.append("-Xfrontend")
            arguments.append(packageName.lowercased())
        }

        arguments.append("-Xcc")
        arguments.append(overridesHmapPath)
        arguments.append(
            contentsOf: getIncludePaths(
                in: NSString(string: derivedDataPath).appendingPathComponent("/SourcePackages/checkouts"),
                ignoredDirectories: ["swift-package-manager"]
            )
        )
        arguments.append("-Xcc")
        arguments.append("-DSWIFT_PACKAGE")
        arguments.append("-Xcc")
        arguments.append("-DDEBUG=1")
        arguments.append("-working-directory")
        arguments.append(getWorkingDirectoryPath(sourceFilePath: targetFilePath))

        return arguments
    }

    public var arguments: [String] {
        let path = [
            //            "-vfsoverlay",
//            derivedDataPath + "/Index.noindex/Build/Intermediates.noindex/index-overlay.yaml",
//            "-module-name",
//            moduleName,
//            "-Onone",
//            "-enforce-exclusivity=checked",
            ""
        ]
//            + sourceFilePaths
//            + [
//                "-DSWIFT_PACKAGE",
//                "-DDEBUG"
//            ]
//            + getModuleMapPaths(derivedDataPath: derivedDataPath)
//            + [
//                "-DXcode",
//                "-sdk",
//                // TODO: Make ↓ dynamically generated
//                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk",
//                "-target",
//                "arm64-apple-macos14.0",
//                "-g",
//                "-module-cache-path",
//                moduleCachePath,
//                "-Xfrontend",
//                "-serialize-debugging-options",
//                "-enable-testing",
//                "-swift-version",
//                "5",
//                "-I",
//                debugPath,
//                "-I",
//                // TODO: Make ↓ dynamically generated
//                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib",
//                "-F",
//                packageFrameworksPath,
//                "-F",
//                debugPath,
//                "-F",
//                // TODO: Make ↓ dynamically generated
//                "/Applications/Xcode-15.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks"
//            ]
//            + getExecutableMacroPaths(derivedDataPath: derivedDataPath)

        return path
//            + [
//                "-Xfrontend",
//                "-experimental-allow-module-with-compiler-errors",
//                "-Xfrontend",
//                "-empty-abi-descriptor",
//                "-Xcc",
//                "-fretain-comments-from-system-headers",
//                "-Xcc",
//                "-Xclang",
//                "-Xcc",
//                "-detailed-preprocessing-record",
//                "-Xcc",
//                "-Xclang",
//                "-Xcc",
//                "-fmodule-format=raw",
//                "-Xcc",
//                "-ferror-limit=10",
//                "-Xcc",
//                "-Xclang",
//                "-Xcc",
//                "-fallow-pch-with-compiler-errors",
//                "-Xcc",
//                "-Xclang",
//                "-Xcc",
//                "-fallow-pcm-with-compiler-errors",
//                "-Xcc",
//                "-Wno-non-modular-include-in-framework-module",
//                "-Xcc",
//                "-Wno-incomplete-umbrella",
//                "-Xcc",
//                "-fmodules-validate-system-headers",
//                "-Xfrontend",
//                "-package-name",
//                "-Xfrontend",
        // TODO: Make ↓ dynamically generated
//                "ragess",
//                "-Xcc",
//                overridesHmapPath
//            ]
//            + getIncludePaths(
//                in: NSString(string: derivedDataPath).appendingPathComponent("/SourcePackages/checkouts"),
//                ignoredDirectories: ["swift-package-manager"]
//            )
//            + [
//                "-Xcc",
//                "-DSWIFT_PACKAGE",
//                "-Xcc",
//                "-DDEBUG=1",
//                "-working-directory",
//                // TODO: Make ↓ dynamically generated
//                "/Users/onaga/RAGESS/RAGESS/RAGESS"
//            ]
    }

//    var moduleCachePath: String {
//        let path = NSString(string: derivedDataPath).deletingLastPathComponent
//        return NSString(string: path).appendingPathComponent("/ModuleCache.noindex")
//    }
//
//    var packageFrameworksPath: String {
//        NSString(string: derivedDataPath).appendingPathComponent("/Index.noindex/Build/Products/Debug/PackageFrameworks")
//    }
//
//    var debugPath: String {
//        NSString(string: derivedDataPath).appendingPathComponent("/Index.noindex/Build/Products/Debug")
//    }
//
//    var overridesHmapPath: String {
//        URL(fileURLWithPath: "-I")
//            .appendingPathComponent(derivedDataPath)
//            .appendingPathComponent("/Index.noindex/Build/Intermediates.noindex/RAGESS.build/Debug/")
//            .appendingPathComponent("\(moduleName).build/swift-overrides.hmap")
//            .path()
//    }

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

    func getPackageName(sourceFilePath: String) -> String? {
        let fileManager = FileManager.default
        var currentDirectory = URL(fileURLWithPath: sourceFilePath).deletingLastPathComponent()

        while currentDirectory.path != "/" {
            let packageSwiftPath = currentDirectory.appendingPathComponent("Package.swift").path
            if fileManager.fileExists(atPath: packageSwiftPath) {
                return currentDirectory.lastPathComponent
            }
            currentDirectory = currentDirectory.deletingLastPathComponent()
        }
        return nil
    }

    func getWorkingDirectoryPath(sourceFilePath: String) -> String {
        let fileManager = FileManager.default
        var currentDirectory = URL(filePath: sourceFilePath).deletingLastPathComponent()

        while currentDirectory.path != "/" {
            let packageSwiftPath = currentDirectory.appendingPathComponent("Package.swift").path
            if fileManager.fileExists(atPath: packageSwiftPath) {
                return currentDirectory.path()
            }
            currentDirectory = currentDirectory.deletingLastPathComponent()
        }

        currentDirectory = URL(filePath: sourceFilePath).deletingLastPathComponent()
        while currentDirectory.path != "/" {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: currentDirectory.path) else {
                currentDirectory = currentDirectory.deletingLastPathComponent()
                continue
            }
            for filePath in contents {
                if URL(filePath: filePath).pathExtension == "xcodeproj" {
                    return currentDirectory.path()
                }
            }
            currentDirectory = currentDirectory.deletingLastPathComponent()
        }

        return URL(filePath: sourceFilePath).deletingLastPathComponent().path()
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

public enum CompilerArgumentGenerationError: Error {
    case notFoundBuildDirectory
    case notFoundSDK
    case notFoundTarget
    case notFoundSwiftVersion
    case notFoundTestLibraryPath
    case notFoundTestFrameworkPath
}
