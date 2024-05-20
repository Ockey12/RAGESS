//
//  MonitorClient.swift
//
//
//  Created by Ockey12 on 2024/05/20
//
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct MonitorClient {
    public var start: @Sendable (_ directoryPath: String) -> AsyncStream<Void> = { _ in .finished }
}

extension MonitorClient: DependencyKey {
    public static let liveValue: MonitorClient = .init(
        start: { directoryPath in
            AsyncStream { continuation in
                let monitor = Monitor(
                    directoryPath: directoryPath,
                    eventHandler: { continuation.yield() }
                )

                continuation.onTermination = { _ in
                    monitor.stopMonitoring()
                }

                monitor.startMonitoring()
            }
        }
    )
}
