//
//  DerivedDataMonitor.swift
//
//
//  Created by Ockey12 on 2024/05/20
//
//

import Foundation

class DerivedDataMonitor {
    let directoryPath: String
    var eventHandler: (() -> Void)?
    private var source: DispatchSourceFileSystemObject?

    init(directoryPath: String, eventHandler: (() -> Void)?) {
        self.directoryPath = directoryPath
        self.eventHandler = eventHandler
    }

    func startMonitoring() {
        let fileDescriptor = open(directoryPath, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("ERROR in \(#file) - \(#function): Failed to open directory in \(directoryPath).")
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: .global()
        )

        source?.setEventHandler { [weak self] in
            self?.eventHandler?()
        }

        source?.setCancelHandler {
            close(fileDescriptor)
        }

        source?.resume()
    }

    func stopMonitoring() {
        source?.cancel()
        source = nil
    }
}
