//
//  DerivedDataMonitorClient.swift
//
//
//  Created by Ockey12 on 2024/05/20
//
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct DerivedDataMonitorClient {
    public var start: @Sendable (_ directoryPath: String) async -> AsyncStream<Void> = { _ in .finished }
}

extension DerivedDataMonitorClient: DependencyKey {
    public static let liveValue: DerivedDataMonitorClient = .init(
        start: { directoryPath in
            AsyncStream { continuation in
                let monitor = DerivedDataMonitor(
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
