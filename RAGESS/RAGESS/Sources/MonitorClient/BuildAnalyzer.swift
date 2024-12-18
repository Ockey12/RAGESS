//
//  BuildAnalyzer.swift
//
//
//  Created by Ockey12 on 2024/12/18
//
//

import Foundation

public class BuildAnalyzer {
    private var monitor: DerivedDataChangeMonitor?

    public init() {}

    public func startAnalyzing(derivedDataPath: String) {
        monitor = DerivedDataChangeMonitor()
        monitor?.startMonitoring(derivedDataPath: derivedDataPath)
    }

    public func stopAnalyzing() {
        monitor?.stopMonitoring()
        monitor = nil
    }
}

class DerivedDataChangeMonitor {
    private var monitors: [String: DispatchSourceFileSystemObject] = [:]
    private var fileDescriptors: [String: Int32] = [:]

    func startMonitoring(derivedDataPath: String) {
        stopMonitoring()

        setupMonitoring(for: derivedDataPath)

        // Monitor subdirectories recursively.
        if let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: derivedDataPath),
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            while let url = enumerator.nextObject() as? URL {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
                   isDirectory.boolValue {
                    setupMonitoring(for: url.path)
                }
            }
        }
    }

    private func setupMonitoring(for path: String) {
        let handle = open(path, O_EVTONLY)
        guard handle != -1 else {
            return
        }
        fileDescriptors[path] = handle

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: handle,
            // `.link` also detects new file creation.
            eventMask: [.write, .link],
            queue: DispatchQueue.global()
        )

        source.setEventHandler { [weak self] in
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"

            // Check the type of event.
            let eventData = source.data
            if eventData.contains(.write) {
                print("🔄 \(formatter.string(from: date)) File modified: \(path)")
            }
            if eventData.contains(.link) {
                // Check for changes in directories, as new files may have been created.
                self?.checkNewFiles(in: path, timestamp: formatter.string(from: date))
            }
        }

        source.setCancelHandler { [handle] in
            close(handle)
        }

        source.resume()
        monitors[path] = source
    }

    private func checkNewFiles(in directoryPath: String, timestamp: String) {
        // Obtain the current list of files to compare with the results of the previous scan.
        if let contents = try? FileManager.default.contentsOfDirectory(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil
        ) {
            for url in contents {
                if !monitors.keys.contains(url.path) {
                    let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                    if isDirectory {
                        // When new directories are discovered, they are also added to the monitoring target.
                        setupMonitoring(for: url.path)
                        print("📁 \(timestamp) New directory detected: \(url.path)")
                    } else {
                        print("📄 \(timestamp) New file detected: \(url.path)")
                    }
                }
            }
        }
    }

    func stopMonitoring() {
        for (_, monitor) in monitors {
            monitor.cancel()
        }
        monitors.removeAll()
        fileDescriptors.removeAll()
    }

    deinit {
        stopMonitoring()
    }
}
