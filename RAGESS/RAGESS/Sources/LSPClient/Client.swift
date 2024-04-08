//
//  Client.swift
//
//
//  Created by ockey12 on 2024/04/09.
//

import LanguageServerProtocol

final class Client: MessageHandler {
    func handle<Notification>(
        _: Notification,
        from: ObjectIdentifier
    ) where Notification: NotificationType {}

    func handle<Request>(
        _: Request,
        id: RequestID,
        from: ObjectIdentifier,
        reply: @escaping (LSPResult<Request.Response>) -> Void
    ) where Request: RequestType {}
}
