//
//  FileStructureDebugger.swift
//
//
//  Created by ockey12 on 2024/04/21.
//

import SourceKittenFramework

public struct FileStructureDebugger {
    let file: File
    let structure: Structure

    public init(filePath: String) throws {
        guard let file = File(path: filePath) else {
            throw JumpToDefinitionError.fileNotFound(filePath)
        }

        self.file = file

        do {
            structure = try Structure(file: file)
        } catch {
            throw JumpToDefinitionError.parseError(error)
        }
    }

    public func printStructure() {
        let descriptions = structure.description.components(separatedBy: "\n")
        for line in descriptions {
            print(line)
        }
        dump(structure.dictionary)
    }
}

enum JumpToDefinitionError: Error {
    case fileNotFound(String)
    case parseError(Error)
}
