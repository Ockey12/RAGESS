//
//  CompilerArgumentsGenerator.swift
//
//
//  Created by ockey12 on 2024/04/27.
//

import Dependencies
import Foundation
import XcodeObject

public struct CompilerArgumentsGenerator {
    public init(
        targetFilePath: String,
        buildSettings: [String: String],
        sourceFilePaths: [String],
        packages: [PackageObject]
    ) {
        self.targetFilePath = targetFilePath
        self.buildSettings = buildSettings
        self.sourceFilePaths = sourceFilePaths
        self.packages = packages
    }

    let targetFilePath: String
    let buildSettings: [String: String]
    let sourceFilePaths: [String]
    let packages: [PackageObject]

    public func generateArguments() async throws -> [String] {
        guard let packageName = getPackageName(sourceFilePath: targetFilePath, buildSettings: buildSettings) else {
            throw CompilerArgumentGenerationError.notFoundPackageName
        }
        guard let moduleName = getModuleName(sourceFilePath: targetFilePath, packages: packages, buildSettings: buildSettings) else {
            throw CompilerArgumentGenerationError.notFoundModuleName
        }
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
            .appendingPathComponent("/Index.noindex/Build/Intermediates.noindex/\(packageName).build/Debug/")
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

        guard let sdkName = buildSettings["SDK_NAME"] else {
            throw CompilerArgumentGenerationError.notFoundSDKName
        }
        guard let sdkVersion = buildSettings["SDK_VERSION"] else {
            throw CompilerArgumentGenerationError.notFoundSDKVersion
        }
        if sdkName.hasPrefix("iphoneos") {
            arguments.append("arm64-apple-ios\(sdkVersion)")
        } else if sdkName.hasPrefix("macosx") {
            arguments.append("arm64-apple-macos\(sdkVersion)")
        } else {
            throw CompilerArgumentGenerationError.unexpectedSDK
        }

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
        if swiftVersion.hasSuffix(".0") {
            arguments.append(String(swiftVersion.dropLast(2)))
        } else {
            arguments.append(swiftVersion)
        }

        arguments.append("-I")
        arguments.append(debugPath)
        arguments.append("-I")

        guard let testLibraryPath = buildSettings["TEST_LIBRARY_SEARCH_PATHS"] else {
            throw CompilerArgumentGenerationError.notFoundTestLibraryPath
        }
        arguments.append(testLibraryPath.trimmingCharacters(in: .whitespaces))
        arguments.append("-F")
        arguments.append(packageFrameworksPath)
        arguments.append("-F")
        arguments.append(debugPath)
        arguments.append("-F")

        guard let testFrameworkPath = buildSettings["TEST_FRAMEWORK_SEARCH_PATHS"] else {
            throw CompilerArgumentGenerationError.notFoundTestFrameworkPath
        }
        arguments.append(testFrameworkPath.trimmingCharacters(in: .whitespaces))
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
        arguments.append("-Xfrontend")
        arguments.append("-package-name")
        arguments.append("-Xfrontend")
        arguments.append(packageName.lowercased())
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

    func getPackageName(sourceFilePath: String, buildSettings: [String: String]) -> String? {
        if let moduleName = buildSettings["PRODUCT_MODULE_NAME"] {
            return moduleName
        }

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

    func getModuleName(sourceFilePath: String, packages: [PackageObject], buildSettings: [String: String]) -> String? {
        guard !packages.isEmpty,
              let packageName = getPackageName(sourceFilePath: sourceFilePath, buildSettings: buildSettings) else {
            return nil
        }
        var sourceDirectory = NSString(string: sourceFilePath).deletingLastPathComponent

        while sourceDirectory != "/" {
            guard let package = packages.filter({ $0.name == packageName }).first else {
                sourceDirectory = NSString(string: sourceDirectory).deletingLastPathComponent
                continue
            }

            let targetName = NSString(string: sourceDirectory).lastPathComponent
            for module in package.modules {
                if targetName == module.name {
                    return module.name
                }
            }

            sourceDirectory = NSString(string: sourceDirectory).deletingLastPathComponent
        }

        return nil
    }

    func getModuleMapPaths(derivedDataPath: String) -> [String] {
        let fileManager = FileManager.default
        let path = NSString(string: derivedDataPath).appendingPathComponent("/Index.noindex/Build/Intermediates.noindex/GeneratedModuleMaps/")
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
        let directoryPath = NSString(string: derivedDataPath).appendingPathComponent("/Index.noindex/Build/Products/Debug/")
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
                let macroPath = NSString(string: directoryPath).appendingPathComponent("\(fileName)#\(fileName)")
                macroPaths.append(macroPath)
            }
        }

        macroPaths = macroPaths.sorted { NSString(string: $0).lastPathComponent < NSString(string: $1).lastPathComponent }
        var arguments: [String] = []
        for path in macroPaths {
            arguments.append("-Xfrontend")
            arguments.append("-load-plugin-executable")
            arguments.append("-Xfrontend")
            arguments.append(path)
        }

        return arguments

        func isExecutable(_ permissions: Int?) -> Bool {
            guard let permissions = permissions else {
                return false
            }

            let executableMask = 0o111
            return permissions & executableMask != 0
        }
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
    case notFoundPackageName
    case notFoundModuleName
    case notFoundBuildDirectory
    case notFoundSDK
    case notFoundTarget
    case notFoundSDKName
    case notFoundSDKVersion
    case unexpectedSDK
    case notFoundSwiftVersion
    case notFoundTestLibraryPath
    case notFoundTestFrameworkPath
}
