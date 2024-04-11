//
//  LSPClient.swift
//
//
//  Created by ockey12 on 2024/04/09.
//

import Dependencies
import DependenciesMacros
import Foundation
import LanguageServerProtocol
import LanguageServerProtocolJSONRPC

@DependencyClient
public struct LSPClient {
    static let clientToServer = Pipe()
    static let serverToClient = Pipe()
    static let serverProcess = Process()
    static let connection = JSONRPCConnection(
        protocol: .lspProtocol,
        inFD: .init(fileDescriptor: Self.serverToClient.fileHandleForReading.fileDescriptor),
        outFD: .init(fileDescriptor: Self.clientToServer.fileHandleForWriting.fileDescriptor)
    )
    static let queue = DispatchQueue(label: "SourceKit-LSP")

    public var sendInitializeRequest: @Sendable (
        _ serverPath: String,
        _ projectRootPathString: String
    ) async throws -> Void

    public var sendInitializedNotification: @Sendable () async throws -> Void

    public var sendDidOpenNotification: @Sendable (
        _ filePathString: String,
        _ sourceCode: String
    ) async throws -> Void

    public var sendDefinitionRequest: @Sendable (
        _ filePathString: String,
        _ position: Position
    ) async throws -> Void
}
