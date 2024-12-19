//
//  BuildMonitor.swift
//
//
//  Created by Ockey12 on 2024/12/18
//
//

import Foundation

public enum BuildEvent {
    case buildStart(date: Date)
    case buildSuccess(date: Date)
}

public final class BuildMonitor {
    private var buildStartMonitor: FileMonitor
    private var buildSuccessMonitor: FileMonitor
    private var continuation: AsyncStream<BuildEvent>.Continuation?

    public init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path()
        buildStartMonitor = FileMonitor(
            filePath: "\(homeDirectory)/RAGESSCache/BuildStartTimeStamps.log"
        )
        buildSuccessMonitor = FileMonitor(
            filePath: "\(homeDirectory)/RAGESSCache/BuildSuccessTimeStamps.log"
        )
    }

    public func monitorBuildEvents() -> AsyncStream<BuildEvent> {
        AsyncStream { continuation in
            self.continuation = continuation

            // Build Start Monitorのセットアップ
            Task {
                for await _ in buildStartMonitor.monitorChanges() {
                    continuation.yield(.buildStart(date: Date()))
                }
            }

            // Build Success Monitorのセットアップ
            Task {
                for await _ in buildSuccessMonitor.monitorChanges() {
                    continuation.yield(.buildSuccess(date: Date()))
                }
            }
        }
    }

    deinit {
        continuation?.finish()
    }
}

private class FileMonitor {
    private var fileHandle: FileHandle?
    private var source: DispatchSourceFileSystemObject?
    private let filePath: String
    private var continuation: AsyncStream<Void>.Continuation?
    private let queue = DispatchQueue(label: "com.FileMonitor.queue")

    init(filePath: String) {
        self.filePath = filePath
        setup()
    }

    private func setup() {
        let fileManager = FileManager.default
        let directoryPath = NSString(string: filePath).deletingLastPathComponent

        do {
            if !fileManager.fileExists(atPath: directoryPath) {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            }

            if !fileManager.fileExists(atPath: filePath) {
                fileManager.createFile(atPath: filePath, contents: nil)
            }
        } catch {
            assertionFailure("Failed to setup directory/file: \(error)")
        }
    }

    func monitorChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            self.continuation = continuation
            startMonitoring()
        }
    }

    private func startMonitoring() {
        do {
            fileHandle = try FileHandle(forReadingFrom: URL(filePath: filePath))

            guard let fileHandle else {
                assertionFailure("Failed to create file handle")
                return
            }

            let descriptor = fileHandle.fileDescriptor

            source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: [.write, .delete, .rename],
                queue: queue
            )

            source?.setEventHandler { [weak self] in
                guard let self,
                      let source else {
                    return
                }

                let eventData = source.data
                if eventData.contains(.write) {
                    self.continuation?.yield(())
                }
                if eventData.contains(.delete) || eventData.contains(.rename) {
                    self.stopMonitoring()
                    self.setup()
                    self.startMonitoring()
                }
            }

            source?.setCancelHandler { [weak self] in
                self?.fileHandle?.closeFile()
                self?.fileHandle = nil
            }

            source?.resume()
        } catch {
            assertionFailure("Failed to start monitoring: \(error)")
        }
    }

    private func stopMonitoring() {
        source?.cancel()
        source = nil
        fileHandle?.closeFile()
        fileHandle = nil
    }

    deinit {
        stopMonitoring()
        continuation?.finish()
    }
}
