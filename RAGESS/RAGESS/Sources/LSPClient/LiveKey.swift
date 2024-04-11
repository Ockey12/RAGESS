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
            print("Sending DidOpen Notification")
            dump(notification)
        },
        sendDefinitionRequest: { filePathString, position in
            let sourceFileURL = URL(fileURLWithPath: filePathString)
            let request = DefinitionRequest(
                textDocument: TextDocumentIdentifier(
                    DocumentURI(sourceFileURL)
                ),
                position: position
            )

            print("Sending DefinitionRequest")
            dump(request)

            _ = connection.send(request, queue: queue) { result in
                switch result {
                case .success(let response):
                    print("\nSuccessfully retrieved the definition location.\n")
                    dump(response)
                case .failure(let error):
                    print("\nFailed to retrieve the definition location.\n")
                    print(error)
                }
            }
        }
    )
}
