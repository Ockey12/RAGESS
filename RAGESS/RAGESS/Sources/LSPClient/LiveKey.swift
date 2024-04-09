//
//  LiveKey.swift
//
//
//  Created by ockey12 on 2024/04/10.
//

import Dependencies
import Foundation
import LanguageServerProtocol
import LanguageServerProtocolJSONRPC

extension LSPClient: DependencyKey {
    public static let liveValue: Self = .init(
        clientToServer: Pipe(),
        serverToClient: Pipe(),
        serverProcess: Process(),
        queue: DispatchQueue(label: "SourceKit-LSP"),
        sendInitializeRequest: { serverPath, projectRootPathString in
            Self.liveValue.serverProcess.launchPath = serverPath
            Self.liveValue.serverProcess.standardInput = Self.liveValue.clientToServer
            Self.liveValue.serverProcess.standardOutput = Self.liveValue.serverToClient
            Self.liveValue.serverProcess.launch()

            let rootURL = URL(fileURLWithPath: projectRootPathString)
            let request = InitializeRequest(
                rootURI: DocumentURI(string: rootURL.absoluteString),
                capabilities: ClientCapabilities(),
                workspaceFolders: nil
            )

            #if DEBUG
                print("Sending InitializedRequest")
                dump(request)
                print("")
            #endif

            let connection = JSONRPCConnection(
                protocol: .lspProtocol,
                inFD: .init(fileDescriptor: Self.liveValue.serverToClient.fileHandleForReading.fileDescriptor),
                outFD: .init(fileDescriptor: Self.liveValue.clientToServer.fileHandleForWriting.fileDescriptor)
            )

            _ = connection.send(request, queue: Self.liveValue.queue) { result in
                switch result {
                case let .success(response):
                    #if DEBUG
                        print("\nINITIALIZATION SUCCEEDED\n")
                        dump(response)
                    #endif
                case let .failure(error):
                    #if DEBUG
                        print("\nINITIALIZATION FAILED...\n")
                        print(error)
                    #endif
                }
            }
        } // sendInitializeRequest
    )
}
