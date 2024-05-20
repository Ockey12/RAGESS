//
//  DerivedDataMonitor.swift
//
//  
//  Created by Ockey12 on 2024/05/20
//  
//

import Foundation
import Cocoa

public class DerivedDataMonitor {
    let directoryPath: String
    private var watchTask: Task<Void, Never>?
    private var changeStream: AsyncStream<Void>?

    public init(directoryPath: String) {
        self.directoryPath = directoryPath
    }

    public func startMonitoring() -> AsyncStream<Void> {
        let stream = AsyncStream<Void> { continuation in
            watchTask = Task {
                let fileDescriptor = open(directoryPath, O_EVTONLY)
                guard fileDescriptor != -1 else {
                    print("Failed to open directory: \(directoryPath)")
                    continuation.finish()
                    return
                }

                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: fileDescriptor,
                    eventMask: .write,
                    queue: .global()
                )

                source.setEventHandler {
                    print("Directory content changed.")
                    continuation.yield()
                }

                source.setCancelHandler {
                    close(fileDescriptor)
                    continuation.finish()
                }

                source.resume()
            }
        }

        changeStream = stream
        return stream
    }

    public func stopMonitoring() {
        watchTask?.cancel()
        watchTask = nil
        changeStream = nil
    }
}
