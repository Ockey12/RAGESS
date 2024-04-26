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
