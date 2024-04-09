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
    let clientToServer: Pipe
    let serverToClient: Pipe
    let serverProcess: Process
    private lazy var connection = JSONRPCConnection(
        protocol: .lspProtocol,
        inFD: .init(fileDescriptor: serverToClient.fileHandleForReading.fileDescriptor),
        outFD: .init(fileDescriptor: clientToServer.fileHandleForWriting.fileDescriptor)
    )
    let queue: DispatchQueue

    public var sendInitializeRequest: @Sendable (
        _ serverPath: String,
        _ projectRootPathString: String
    ) async throws -> Void

    mutating func sendInitializeRequest(
        serverPath: String =
            "/Applications/Xcode-15.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
        projectRootPathString: String
    ) {
        connection.start(receiveHandler: Client())

        serverProcess.launchPath = serverPath
        serverProcess.standardInput = clientToServer
        serverProcess.standardOutput = serverToClient
//        serverProcess.terminationHandler = { _ in
//            self?.connection.close()
//        }
        serverProcess.launch()

        let rootURL = URL(fileURLWithPath: projectRootPathString)
        let request = InitializeRequest(
            rootURI: DocumentURI(string: rootURL.absoluteString),
            capabilities: ClientCapabilities(),
            workspaceFolders: nil
        )

        print("Sending InitializedRequest")
        dump(request)
        print("")

        _ = connection.send(request, queue: queue) { result in
            switch result {
            case let .success(response):
                print("\nINITIALIZATION SUCCEEDED\n")
                dump(response)
            case let .failure(error):
                print("\nINITIALIZATION FAILED...\n")
                print(error)
            }
        }
    } // func sendInitializeRequest
}
