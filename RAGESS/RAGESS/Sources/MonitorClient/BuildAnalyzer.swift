//
//  BuildAnalyzer.swift
//
//
//  Created by Ockey12 on 2024/12/18
//
//

import Foundation

public class BuildAnalyzer {
    private var monitor: BuildDirectoriesMonitor?

    public init() {}

    public func startAnalyzing(derivedDataPath: String) {
        monitor = BuildDirectoriesMonitor()
        monitor?.startMonitoring(derivedDataPath: derivedDataPath)
    }

    public func stopAnalyzing() {
        monitor?.stopMonitoring()
        monitor = nil
    }
}

class BuildDirectoriesMonitor {
    private var derivedDataMonitor: DispatchSourceFileSystemObject?
    private var buildLogsMonitor: DispatchSourceFileSystemObject?
    private var buildProductsMonitor: DispatchSourceFileSystemObject?
    private var derivedDataFileDescriptor: Int32 = -1
    private var buildLogsFileDescriptor: Int32 = -1
    private var buildProductsFileDescriptor: Int32 = -1

    enum DirectoryType: String {
        case derivedData = "DerivedData"
        case buildLogs = "Logs/Build"
        case buildProducts = "Build/Products"
    }

    func startMonitoring(derivedDataPath: String) {
        stopMonitoring()

        setupMonitor(
            path: derivedDataPath,
            type: .derivedData,
            fileDescriptor: &derivedDataFileDescriptor,
            monitor: &derivedDataMonitor
        )

        let buildLogsPath = (derivedDataPath as NSString).appendingPathComponent("Logs/Build")
        setupMonitor(
            path: buildLogsPath,
            type: .buildLogs,
            fileDescriptor: &buildLogsFileDescriptor,
            monitor: &buildLogsMonitor
        )

        let buildProductsPath = (derivedDataPath as NSString).appendingPathComponent("Build/Products")
        setupMonitor(
            path: buildProductsPath,
            type: .buildProducts,
            fileDescriptor: &buildProductsFileDescriptor,
            monitor: &buildProductsMonitor
        )
    }

    private func setupMonitor(
        path: String,
        type: DirectoryType,
        fileDescriptor: inout Int32,
        monitor: inout DispatchSourceFileSystemObject?
    ) {
        let handle = open(path, O_EVTONLY)
        if handle == -1 {
            let error = String(cString: strerror(errno))
            print("Failed to open file descriptor for \(type.rawValue) path: \(path)")
            print("Error: \(error)")
            return
        }
        fileDescriptor = handle

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: handle,
            eventMask: [.write, .link],
            queue: DispatchQueue.global()
        )

        source.setEventHandler { [weak self] in
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            let timestamp = formatter.string(from: date)

            let eventData = source.data
            if eventData.contains(.write) {
                print("🔄 \(timestamp) [\(type.rawValue)] Directory modified: \(path)")
            }
            if eventData.contains(.link) {
                print("🔗 \(timestamp) [\(type.rawValue)] Link event: \(path)")
            }
        }

        source.setCancelHandler { [handle] in
            close(handle)
        }

        source.resume()
        monitor = source
    }

    func stopMonitoring() {
        // DerivedDataの監視を停止
        if let monitor = derivedDataMonitor {
            monitor.cancel()
            derivedDataMonitor = nil
        }

        // Build Logsの監視を停止
        if let monitor = buildLogsMonitor {
            monitor.cancel()
            buildLogsMonitor = nil
        }

        if let monitor = buildProductsMonitor {
            monitor.cancel()
            buildProductsMonitor = nil
        }
    }

    deinit {
        stopMonitoring()
    }
}
