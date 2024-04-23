//
//  JumpToDefinition.swift
//
//
//  Created by ockey12 on 2024/04/21.
//

import SourceKittenFramework

public struct JumpToDefinition {
    let file: File
    let structure: Structure

    public init(filePath: String) throws {
        guard let file = File(path: filePath) else {
            throw JumpToDefinitionError.fileNotFound(filePath)
        }

        self.file = file

        do {
            self.structure = try Structure(file: file)
        } catch {
            throw JumpToDefinitionError.parseError(error)
        }
    }

//    func findDefinition(symbolName: String) -> (filePath: String, line: Int, column: Int)? {
    public func findDefinition(symbolName: String) {
        let descriptions = structure.description.components(separatedBy: "\n")
//        dump(structure.description)
        for line in descriptions {
            print(line)
        }
        dump(structure.dictionary)
//        guard let symbol = structure.dictionary.first(where: { dictionary in
//            dictionary.key == symbolName
//        }) else {
//            return
//        }
//
//        dump(symbol)

//        guard let offset = symbol.offset,
//              let length = symbol.length,
//              let filePath = symbol.filePath else {
//            return nil
//        }
//
//        let location = structure.stringView.lineAndCharacter(forByteOffset: ByteCount(offset))
//        let line = location.line
//        let column = location.character
//
//        return (filePath, line, column)
    }
}

enum JumpToDefinitionError: Error {
    case fileNotFound(String)
    case parseError(Error)
}
