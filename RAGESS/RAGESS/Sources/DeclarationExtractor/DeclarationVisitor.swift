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
        #if DEBUG
            print("\nvisit(ProtocolDeclSyntax(\(node.name.text)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(ProtocolDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentProtocol = buffer.popLast(),
              currentProtocol.kind == .protocol
        else {
            fatalError("The type of the last element of buffer is not a protocol.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var protocolOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingProtocols.append(\(currentProtocol.name))")
            #endif
            protocolOwner.nestingProtocols.append(currentProtocol)
            buffer.append(protocolOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentProtocol.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentProtocol)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: StructDeclSyntax

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(StructDeclSyntax(\(node.name.text)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(StructDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentStruct = buffer.popLast(),
              currentStruct.kind == .struct
        else {
            fatalError("The type of the last element of buffer is not a struct.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var structOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingStructs.append(\(currentStruct.name))")
            #endif
            structOwner.nestingStructs.append(currentStruct)
            buffer.append(structOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentStruct.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentStruct)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: ClassDeclSyntax

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(ClassDeclSyntax(\(node.name.text)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(ClassDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentClass = buffer.popLast() else {
            fatalError("The type of the last element of buffer is not a class.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var classOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingClasses.append(\(currentClass.name))")
            #endif
            classOwner.nestingClasses.append(currentClass)
            buffer.append(classOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentClass.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentClass)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: EnumDeclSyntax

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(EnumDeclSyntax(\(node.name.text)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(EnumDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentEnum = buffer.popLast(),
              currentEnum.kind == .enum
        else {
            fatalError("The type of the last element of buffer is not a enum.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var enumOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingEnums.append(\(currentEnum.name))")
            #endif
            enumOwner.nestingEnums.append(currentEnum)
            buffer.append(enumOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentEnum.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentEnum)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: ActorDeclSyntax

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(ActorDeclSyntax(\(node.name.text))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(ActorDeclSyntax(\(node.name.text))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentActor = buffer.popLast(),
              currentActor.kind == .actor
        else {
            fatalError("The type of the last element of buffer is not a actor.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var actorOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingActors.append(\(currentActor.name)")
            #endif
            actorOwner.nestingActors.append(currentActor)
            buffer.append(actorOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentActor.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentActor)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: InitializerDeclSyntax

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(InitializerDeclSyntax(\(node.description)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(InitializerDeclSyntax(\(node.description)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentInitializer = buffer.popLast(),
              currentInitializer.kind == .initializer
        else {
            fatalError("The type of the last element of buffer is not a initializer.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var initializerOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].functions.append(\(currentInitializer.name))")
            #endif
            initializerOwner.initializers.append(currentInitializer)
            buffer.append(initializerOwner)
        } else {
            fatalError("Cannot find the holder of the initializer.")
        }
    }

    // MARK: VariableDeclSyntax

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(VariableDeclSyntax(\n\(node)\n))")
        #endif

        let array = Array(node.bindings)
        guard !array.isEmpty else {
            #if DEBUG
                print("The contents of the variable do not exist.")
            #endif
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
        #if DEBUG
            print("\nvisitPost(VariableDeclSyntax(\(node)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentVariable = buffer.popLast(),
              currentVariable.kind == .variable
        else {
            fatalError("The type of the last element of buffer is not a variable.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var variableOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].variables.append(\(currentVariable.name))")
            #endif
            variableOwner.variables.append(currentVariable)
            buffer.append(variableOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentVariable.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentVariable)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: FunctionDeclSyntax

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(FunctionDeclSyntax(\(node.name.text)))")
        #endif
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
        #if DEBUG
            print("\nvisitPost(FunctionDeclSyntax(\(node.name.text)))")
        #endif

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        #if DEBUG
            print("buffer.popLast()")
            print("- \(buffer.map { $0.name })")
        #endif

        guard let currentFunction = buffer.popLast(),
              currentFunction.kind == .function
        else {
            fatalError("The type of the last element of buffer is not a function.")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var functionOwner = buffer.popLast() else {
                fatalError("The buffer is empty.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].functions.append(\(currentFunction.name))")
            #endif
            functionOwner.functions.append(currentFunction)
            buffer.append(functionOwner)
        } else {
            #if DEBUG
                print("extractedDeclarations.append(\(currentFunction.name))")
                print("- \(extractedDeclarations.map { $0.name })")
            #endif
            extractedDeclarations.append(currentFunction)
            #if DEBUG
                print("+ \(extractedDeclarations.map { $0.name })")
            #endif
        }
    }

    // MARK: EnumCaseDeclSyntax

    override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(EnumCaseDeclSyntax(\(node.description)))")
            print("node.elements")
            print("    \(node.elements)")
            print("node.elements.trimmedByteRange.offset: \(node.elements.trimmedByteRange.offset)")

        #endif

        let locationRange = node.sourceRange(converter: locationConverter)
        let rangeInXcode = LocationInXcode(line: locationRange.start.line, column: locationRange.start.column)
            ... LocationInXcode(line: locationRange.end.line, column: locationRange.end.column)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentCase = DeclaredObject(
            // FIXME: Extract the actual case name.
            name: "case",
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

        #if DEBUG
            print("buffer[\(buffer.count)].cases.append(currentCase)")
        #endif

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
        #if DEBUG
            print("buffer.append(\(object.name))")
            print("- \(buffer.map { $0.name })")
        #endif

        buffer.append(object)

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif
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
