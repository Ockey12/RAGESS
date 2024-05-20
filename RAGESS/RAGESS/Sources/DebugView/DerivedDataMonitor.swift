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
        var directoryPath: String

        public init(directoryPath: String) {
            self.directoryPath = directoryPath
        }
    }

    public enum Action {
        case startMonitoringTapped
        case stopMonitoringTapped
        case detectedDirectoryChange
    }

    @Dependency(DerivedDataMonitorClient.self) var monitorClient

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .startMonitoringTapped:
                return .none

            case .stopMonitoringTapped:
                return .none

            case .detectedDirectoryChange:
                return .none
            }
        }
    }
}
