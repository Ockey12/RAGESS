//
//  DerivedDataMonitor.swift
//
//
//  Created by Ockey12 on 2024/05/20
//
//

import ComposableArchitecture
import MonitorClient
import SwiftUI

@Reducer
public struct MonitorClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var derivedDataPath: String
        var buildSettings: [String: String]

        public init(derivedDataPath: String, buildSettings: [String: String]) {
            self.derivedDataPath = derivedDataPath
            self.buildSettings = buildSettings
        }
    }

    public enum Action: BindableAction {
        case startMonitoringTapped
        case stopMonitoringTapped
        case detectedDirectoryChange(String)
        case binding(BindingAction<State>)
    }

    @Dependency(MonitorClient.self) var monitorClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMonitoringTapped:
                guard let buildDirectory = state.buildSettings["BUILD_DIR"] else {
                    #if DEBUG
                        print("ERROR in \(#file): Cannot \"BUILD_DIR\" key in \(MonitorClientDebugger.State.self).")
                    #endif
                    return .none
                }

                let appPaths = findAppPaths(in: buildDirectory)

                return .run { send in
                    for appPath in appPaths {
                        #if DEBUG
                            print("Start monitoring \(appPath)")
                        #endif
                        for await _ in monitorClient.start(directoryPath: appPath) {
                            await send(.detectedDirectoryChange(appPath))
                        }
                    }
                }

            case .stopMonitoringTapped:
                return .none

            case let .detectedDirectoryChange(appPath):
                #if DEBUG
                    print("DerivedDataMonitorClient detected a change in \(appPath).")
                #endif
                return .none

            case .binding:
                return .none
            }
        }
    }
}

extension MonitorClientDebugger {
    func findAppPaths(in directoryPath: String) -> [String] {
        let fileManager = FileManager.default
        let directoryURL = URL(filePath: directoryPath)

        guard let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }

        var appPaths: [String] = []

        while let url = enumerator.nextObject() as? URL {
            if url.pathExtension == "app" {
                appPaths.append(url.path())
            }
        }

        return appPaths
    }
}

public struct MonitorClientDebugView: View {
    @Bindable public var store: StoreOf<MonitorClientDebugger>

    public init(store: StoreOf<MonitorClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        Form {
            TextField("DerivedData Directory Path", text: $store.derivedDataPath)
            Button("Start Monitoring") {
                store.send(.startMonitoringTapped)
            }
        }
    }
}
