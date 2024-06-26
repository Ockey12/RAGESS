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
        sendInitializeRequest: { serverPath, projectRootPathString in
            connection.start(receiveHandler: Client())

            serverProcess.launchPath = serverPath
            serverProcess.standardInput = clientToServer
            serverProcess.standardOutput = serverToClient
            serverProcess.launch()

            let rootURL = URL(fileURLWithPath: projectRootPathString)
            let request = InitializeRequest(
                rootURI: DocumentURI(string: rootURL.absoluteString),
                capabilities: ClientCapabilities(),
                workspaceFolders: nil
            )

            #if DEBUG
                print("Sending InitializedRequest")
                dump(request)
            #endif

            _ = connection.send(request, queue: queue) { result in
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
        },
        sendInitializedNotification: {
            let notification = InitializedNotification()
            connection.send(notification)
            #if DEBUG
                print("Sending InitializedNotification")
                dump(notification)
            #endif
        },
        sendDidOpenNotification: { filePathString, sourceCode in
            let sourceFileURL = URL(fileURLWithPath: filePathString)
            let document = TextDocumentItem(
                uri: DocumentURI(sourceFileURL),
                language: .swift,
                version: 1,
                text: sourceCode
            )

            let notification = DidOpenTextDocumentNotification(textDocument: document)
            connection.send(notification)
            #if DEBUG
                print("Sending DidOpen Notification")
                dump(notification)
            #endif
        },
        sendInlayHintRequest: { sourceFile, range in
            let sourceFileURL = URL(fileURLWithPath: sourceFile.path)
            let request = InlayHintRequest(
                textDocument: TextDocumentIdentifier(
                    DocumentURI(sourceFileURL)
                ),
                range: Position(line: 0, utf16index: 0) ..< sourceFile.content.lastPosition
            )

            #if DEBUG
                print("Sending InlayHintRequest")
                dump(request)
            #endif
            do {
                let inlayHints = try await withCheckedThrowingContinuation { continuation in
                    _ = connection.send(request, queue: queue) { response in
                        switch response {
                        case let .success(inlayHints):
                            continuation.resume(returning: inlayHints)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                #if DEBUG
                    print("\nSuccessfully retrieved the inlay hint.\n")
                    dump(inlayHints)
                #endif
                return inlayHints
            } catch {
                #if DEBUG
                    print("\nFailed to retrieve the inlay hint.\n")
                    print(error)
                #endif
                throw error
            }
        },
        sendDefinitionRequest: { filePathString, position in
            let sourceFileURL = URL(fileURLWithPath: filePathString)
            let request = DefinitionRequest(
                textDocument: TextDocumentIdentifier(
                    DocumentURI(sourceFileURL)
                ),
                position: position
            )

            #if DEBUG
                print("Sending DefinitionRequest")
                dump(request)
            #endif

            _ = connection.send(request, queue: queue) { result in
                switch result {
                case let .success(response):
                    #if DEBUG
                        print("\nSuccessfully retrieved the definition location.\n")
                        dump(response)
                    #endif
                case let .failure(error):
                    #if DEBUG
                        print("\nFailed to retrieve the definition location.\n")
                        print(error)
                    #endif
                }
            }
        }
    )
}
