//
//  DeclarationVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import DeclaredObject
import SwiftSyntax

final class DeclarationVisitor: SyntaxVisitor {
    let fullPath: String
    private(set) var extractedDeclarations: [DeclaredObject] = []
    private var buffer: [DeclaredObject] = []

    private let locationConverter: SourceLocationConverter

    init(in fullPath: String, locatonConverter: SourceLocationConverter) {
        self.fullPath = fullPath
        locationConverter = locatonConverter
        super.init(viewMode: .fixedUp)
    }

    // MARK: ProtocolDeclSyntax

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentProtocol = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .protocol
        )

        appendToBuffer(currentProtocol)

        return .visitChildren
    }

    override func visitPost(_ node: ProtocolDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var currentProtocol = buffer.popLast(),
              currentProtocol.kind == .protocol
        else {
            fatalError("The type of the last element of buffer is not a protocol.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var protocolOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            currentProtocol.addOuterEnclosingTypeName(protocolOwner.name)
            protocolOwner.nestingProtocols.append(currentProtocol)
            buffer.append(protocolOwner)
        } else {
            extractedDeclarations.append(currentProtocol)
        }
    }

    // MARK: StructDeclSyntax

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentStruct = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .struct
        )

        appendToBuffer(currentStruct)

        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var currentStruct = buffer.popLast(),
              currentStruct.kind == .struct
        else {
            fatalError("The type of the last element of buffer is not a struct.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var structOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            currentStruct.addOuterEnclosingTypeName(structOwner.name)
            structOwner.nestingStructs.append(currentStruct)
            buffer.append(structOwner)
        } else {
            extractedDeclarations.append(currentStruct)
        }
    }

    // MARK: ClassDeclSyntax

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentClass = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .class
        )

        appendToBuffer(currentClass)

        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var currentClass = buffer.popLast() else {
            fatalError("The type of the last element of buffer is not a class.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var classOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            currentClass.addOuterEnclosingTypeName(classOwner.name)
            classOwner.nestingClasses.append(currentClass)
            buffer.append(classOwner)
        } else {
            extractedDeclarations.append(currentClass)
        }
    }

    // MARK: EnumDeclSyntax

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentEnum = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .enum
        )

        appendToBuffer(currentEnum)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var currentEnum = buffer.popLast(),
              currentEnum.kind == .enum
        else {
            fatalError("The type of the last element of buffer is not a enum.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var enumOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            currentEnum.addOuterEnclosingTypeName(enumOwner.name)
            enumOwner.nestingEnums.append(currentEnum)
            buffer.append(enumOwner)
        } else {
            extractedDeclarations.append(currentEnum)
        }
    }

    // MARK: ActorDeclSyntax

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentActor = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .actor
        )

        appendToBuffer(currentActor)
        return .visitChildren
    }

    override func visitPost(_ node: ActorDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var currentActor = buffer.popLast(),
              currentActor.kind == .actor
        else {
            fatalError("The type of the last element of buffer is not a actor.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var actorOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            currentActor.addOuterEnclosingTypeName(actorOwner.name)
            actorOwner.nestingActors.append(currentActor)
            buffer.append(actorOwner)
        } else {
            extractedDeclarations.append(currentActor)
        }
    }

    // MARK: ExtensionDeclSyntax

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        appendToBuffer(
            .init(
                name: "\(node.trimmed.extendedType) \(node.trimmed.genericWhereClause?.description ?? "")",
                nameOffset: node.trimmed.extendedType.trimmedByteRange.offset,
                fullPath: fullPath,
                sourceCode: trimSourceCode(node.description),
                rangeInXcode: rangeInXcode,
                offsetRange: offsetRange,
                kind: .extension
            )
        )

        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard let currentExtension = buffer.popLast(),
              currentExtension.kind == .extension
        else {
            fatalError("The type of the last element of buffer is not a extension.")
        }

        extractedDeclarations.append(currentExtension)
    }

    // MARK: InitializerDeclSyntax

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)

        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentInitializer = DeclaredObject(
            name: "init",
            nameOffset: node.initKeyword.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .initializer
        )

        appendToBuffer(currentInitializer)

        return .visitChildren
    }

    override func visitPost(_ node: InitializerDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard let currentInitializer = buffer.popLast(),
              currentInitializer.kind == .initializer
        else {
            fatalError("The type of the last element of buffer is not a initializer.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var initializerOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            initializerOwner.initializers.append(currentInitializer)
            buffer.append(initializerOwner)
        } else {
            fatalError("Cannot find the holder of the initializer.")
        }
    }

    // MARK: VariableDeclSyntax

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let array = Array(node.bindings)
        guard !array.isEmpty else {
            return .visitChildren
        }

        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentVariable = DeclaredObject(
            // FIXME: This element does not necessarily represent the name of the variable.
            // For example, in the case of Tuple Decomposition, the tuple would be the name of the variable.
            // When `let (a, b, c) = (0, 1, 2)`, the variable name becomes “(a, b, c)”.
            name: array[0].pattern.trimmed.description,
            nameOffset: array[0].pattern.trimmed.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .variable
        )

        appendToBuffer(currentVariable)

        return .visitChildren
    }

    override func visitPost(_ node: VariableDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard let currentVariable = buffer.popLast(),
              currentVariable.kind == .variable
        else {
            fatalError("The type of the last element of buffer is not a variable.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var variableOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            variableOwner.variables.append(currentVariable)
            buffer.append(variableOwner)
        } else {
            extractedDeclarations.append(currentVariable)
        }
    }

    // MARK: FunctionDeclSyntax

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentFunction = DeclaredObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .function
        )

        appendToBuffer(currentFunction)

        return .visitChildren
    }

    override func visitPost(_ node: FunctionDeclSyntax) {
        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard let currentFunction = buffer.popLast(),
              currentFunction.kind == .function
        else {
            fatalError("The type of the last element of buffer is not a function.")
        }

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var functionOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            functionOwner.functions.append(currentFunction)
            buffer.append(functionOwner)
        } else {
            extractedDeclarations.append(currentFunction)
        }
    }

    // MARK: EnumCaseDeclSyntax

    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentCase = DeclaredObject(
            name: node.trimmed.description,
            nameOffset: node.elements.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            rangeInXcode: rangeInXcode,
            offsetRange: offsetRange,
            kind: .case
        )

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }
        guard var enumObject = buffer.popLast(),
              enumObject.kind == .enum
        else {
            fatalError("The type of the last element of buffer is not a enum.")
        }

        enumObject.cases.append(currentCase)
        buffer.append(enumObject)

        return .visitChildren
    }

    // MARK: Attribute

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        if !buffer.isEmpty,
           var owner = buffer.popLast() {
            let locationRange = node.sourceRange(converter: locationConverter)
            let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
                ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
            let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

            owner.attributes.append(
                DeclaredObject(
                    name: node.trimmed.description,
                    nameOffset: node.trimmedByteRange.offset,
                    fullPath: fullPath,
                    sourceCode: trimSourceCode(node.description),
                    rangeInXcode: rangeInXcode,
                    offsetRange: offsetRange,
                    kind: .attribute
                )
            )
            buffer.append(owner)
        }

        return .visitChildren
    }
}

extension DeclarationVisitor {
    private func appendToBuffer(_ object: DeclaredObject) {
        buffer.append(object)
    }

    // FIXME: If a String exists in the source code and “\n” exists in the String, a new line is broken.
    private func trimSourceCode(_ sourceCode: String) -> String {
        let lines = sourceCode.components(separatedBy: .newlines)
        var trimmedHeadBlankLins = lines

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                trimmedHeadBlankLins = Array(trimmedHeadBlankLins.dropFirst())
                continue
            }
            break
        }

        let result = trimLeadingSpaces(trimmedHeadBlankLins.joined(separator: "\n"))

        return result
    }

    // FIXME: If a String exists in the source code and “\n” exists in the String, a new line is broken.
    private func trimLeadingSpaces(_ sourceCode: String) -> String {
        let lines = sourceCode.components(separatedBy: .newlines)
        var minSpaces = Int.max

        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            let spaces = line.prefix(while: \.isWhitespace).count
            minSpaces = min(minSpaces, spaces)
        }

        let result = lines.map { line in
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return line
            } else {
                return String(line.dropFirst(minSpaces))
            }
        }.joined(separator: "\n")

        return result
    }
}

enum SyntaxVisitError: Error {
    case doesNotMuchLastElementTypeOfBuffer
}
