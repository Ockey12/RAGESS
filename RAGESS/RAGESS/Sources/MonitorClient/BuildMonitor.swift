//
//  BuildMonitor.swift
//
//
//  Created by Ockey12 on 2024/12/18
//
//

import Foundation

public final class BuildMonitor {
    private var buildStartMonitor: FileMonitor
    private var buildSuccessMonitor: FileMonitor

    public init(onBuildStartHandler: @escaping () -> Void, onBuildSuccessHander: @escaping () -> Void) {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path()
        self.buildStartMonitor = FileMonitor(
            filePath: "\(homeDirectory)/RAGESSCache/BuildStartTimeStamps.log",
            onChangeHandler: onBuildStartHandler
        )
        self.buildSuccessMonitor = FileMonitor(
            filePath: "\(homeDirectory)/RAGESSCache/BuildSuccessTimeStamps.log",
            onChangeHandler: onBuildSuccessHander
        )
    }

    public func startMonitoring() {
        buildStartMonitor.startMonitoring()
        buildSuccessMonitor.startMonitoring()
    }

    public func stopMonitoring() {
        buildStartMonitor.stopMonitoring()
        buildSuccessMonitor.stopMonitoring()
    }

    deinit {
        stopMonitoring()
    }
}

private class FileMonitor {
    private var fileHandle: FileHandle?
    private var source: DispatchSourceFileSystemObject?
    private let filePath: String
    private let onChangeHandler: () -> Void
    private let queue = DispatchQueue(label: "com.FileMonitor.queue")

    init(filePath: String, onChangeHandler: @escaping () -> Void) {
        self.filePath = filePath
        self.onChangeHandler = onChangeHandler
    }

    private func setup() {
        let fileManager = FileManager.default
        let directoryPath = NSString(string: filePath).deletingLastPathComponent

        do {
            // If the directory does not exist, create it.
            if !fileManager.fileExists(atPath: directoryPath) {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            }

            // If the file does not exist, create it.
            if !fileManager.fileExists(atPath: filePath) {
                fileManager.createFile(atPath: filePath, contents: nil)
            }
        } catch {
            assertionFailure()
        }
    }

    func startMonitoring() {
        do {
            fileHandle = try FileHandle(forReadingFrom: URL(filePath: filePath))

            guard let fileHandle else {
                assertionFailure()
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
                      let source
                else {
                    return
                }

                let eventData = source.data
                if eventData.contains(.write) {
                    self.onChangeHandler()
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
            assertionFailure()
        }
    }

    func stopMonitoring() {
        source?.cancel()
        source = nil
        fileHandle?.closeFile()
        fileHandle = nil
    }

    deinit {
        stopMonitoring()
    }
}
