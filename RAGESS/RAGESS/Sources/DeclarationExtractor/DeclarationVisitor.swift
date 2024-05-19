//
//  DeclarationVisitor.swift
//
//
//  Created by ockey12 on 2024/05/05.
//

import SwiftSyntax
import TypeDeclaration

final class DeclarationVisitor: SyntaxVisitor {
    let fullPath: String
    private(set) var extractedDeclarations: [any DeclarationObject] = []
    private var buffer: [any DeclarationObject] = []

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
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentProtocol = ProtocolObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentProtocol = lastItem as? ProtocolObject else {
            fatalError("The type of the last element of buffer is not a \(ProtocolObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let lastItem = buffer.popLast(),
                  var protocolOwner = lastItem as? any TypeNestable else {
                fatalError("The type of the last element of buffer does not conform to TypeNestable.")
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
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentStruct = StructObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentStruct = lastItem as? StructObject else {
            fatalError("The type of the last element of buffer is not a \(StructObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? any TypeNestable else {
                fatalError("The type of the last element of buffer does not conform to TypeNestable.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingStructs.append(\(currentStruct.name))")
            #endif
            ownerTypeObject.nestingStructs.append(currentStruct)
            buffer.append(ownerTypeObject)
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
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentClass = ClassObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentClass = lastItem as? ClassObject else {
            fatalError("The type of the last element of buffer is not a \(ClassObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? any TypeNestable else {
                fatalError("The type of the last element of buffer does not conform to TypeNestable.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingClasses.append(\(currentClass.name))")
            #endif
            ownerTypeObject.nestingClasses.append(currentClass)
            buffer.append(ownerTypeObject)
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
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentEnum = EnumObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentEnum = lastItem as? EnumObject else {
            fatalError("The type of the last element of buffer is not a \(EnumObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let owner = buffer.popLast(),
                  var ownerTypeObject = owner as? any TypeNestable else {
                fatalError("The type of the last element of buffer does not conform to TypeNestable.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].nestingEnums.append(\(currentEnum.name))")
            #endif
            ownerTypeObject.nestingEnums.append(currentEnum)
            buffer.append(ownerTypeObject)
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

    // MARK: InitializerDeclSyntax

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        #if DEBUG
            print("\nvisit(InitializerDeclSyntax(\(node.description)))")
        #endif
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentInitializer = InitializerObject(
            name: "init",
            nameOffset: node.initKeyword.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentInitializer = lastItem as? InitializerObject else {
            fatalError("The type of the last element of buffer is not a \(InitializerObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard let lastItem = buffer.popLast(),
                  var ownerObject = lastItem as? any Initializable else {
                fatalError("The type of the last element of buffer does not conform to Initializable.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].functions.append(\(currentInitializer.name))")
            #endif
            ownerObject.initializers.append(currentInitializer)
            buffer.append(ownerObject)
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

        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentVariable = VariableObject(
            // FIXME: This element does not necessarily represent the name of the variable.
            // For example, in the case of Tuple Decomposition, the tuple would be the name of the variable.
            // When `let (a, b, c) = (0, 1, 2)`, the variable name becomes “(a, b, c)”.
            name: array[0].pattern.trimmed.description,
            nameOffset: array[0].pattern.trimmed.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentVariable = lastItem as? VariableObject else {
            fatalError("The type of the last element of buffer is not a \(VariableObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var ownerObject = buffer.popLast() else {
                fatalError("The type of the last element of buffer does not conform to DeclarationObject.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].variables.append(\(currentVariable.name))")
            #endif
            ownerObject.variables.append(currentVariable)
            buffer.append(ownerObject)
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
        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentFunction = FunctionObject(
            name: node.name.text,
            nameOffset: node.name.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
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

        guard let lastItem = buffer.popLast(),
              let currentFunction = lastItem as? FunctionObject else {
            fatalError("The type of the last element of buffer is not a \(FunctionObject.self).")
        }

        #if DEBUG
            print("+ \(buffer.map { $0.name })")
        #endif

        if buffer.count >= 1 {
            // If there is an element in the buffer, the last element in the buffer is the parent of this.
            guard var ownerObject = buffer.popLast() else {
                fatalError("The type of the last element of buffer does not conform to DeclarationObject.")
            }
            #if DEBUG
                print("buffer[\(buffer.count)].functions.append(\(currentFunction.name))")
            #endif
            ownerObject.functions.append(currentFunction)
            buffer.append(ownerObject)
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

        let positionRange = node.sourceRange(converter: locationConverter)
        let offsetRange = node.trimmedByteRange.offset ... node.trimmedByteRange.endOffset

        let currentCase = EnumObject.CaseObject(
            nameOffset: node.elements.trimmedByteRange.offset,
            fullPath: fullPath,
            sourceCode: trimSourceCode(node.description),
            positionRange: SourcePosition(
                line: positionRange.start.line,
                utf8index: positionRange.start.column
            )
                ... SourcePosition(
                    line: positionRange.end.line,
                    utf8index: positionRange.end.column
                ),
            offsetRange: offsetRange
        )

        guard !buffer.isEmpty else {
            fatalError("The buffer is empty.")
        }

        guard let lastItem = buffer.popLast(),
              var enumObject = lastItem as? EnumObject else {
            fatalError("The type of the last element of buffer is not a \(EnumObject.self).")
        }

        enumObject.cases.append(currentCase)
        buffer.append(enumObject)

        #if DEBUG
            print("buffer[\(buffer.count)].cases.append(currentCase)")
        #endif

        return .visitChildren
    }
}

extension DeclarationVisitor {
    private func appendToBuffer(_ object: any DeclarationObject) {
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
