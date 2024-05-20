//
//  DerivedDataMonitor.swift
//
//
//  Created by Ockey12 on 2024/05/20
//
//

import ComposableArchitecture
import DerivedDataMonitorClient
import SwiftUI

@Reducer
public struct DerivedDataMonitorDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var derivedDataPath: String
        var buildSettings: [String: String]

        public init(derivedDataPath: String, buildSettings: [String : String]) {
            self.derivedDataPath = derivedDataPath
            self.buildSettings = buildSettings
        }
    }

    public enum Action: BindableAction {
        case startMonitoringTapped
        case stopMonitoringTapped
        case detectedDirectoryChange
        case binding(BindingAction<State>)
    }

    @Dependency(DerivedDataMonitorClient.self) var monitorClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMonitoringTapped:
                guard let buildDirectory = state.buildSettings["BUILD_DIR"] else {
                    #if DEBUG
                        print("ERROR in \(#file): Cannot \"BUILD_DIR\" key in \(DerivedDataMonitorDebugger.State.self).")
                    #endif
                    return .none
                }

                let derivedDataPath = URL(filePath: buildDirectory)
                    .deletingLastPathComponent()
                    .deletingLastPathComponent()
                    .path()
                state.derivedDataPath = derivedDataPath

                return .run { send in
                    for await _ in monitorClient.start(directoryPath: derivedDataPath) {
                        await send(.detectedDirectoryChange)
                    }
                }

            case .stopMonitoringTapped:
                return .none

            case .detectedDirectoryChange:
                #if DEBUG
                    print("DerivedDataMonitorClient detected a change in \(state.derivedDataPath).")
                #endif
                return .none

            case .binding:
                return .none
            }
        }
    }
}
