//
//  SourceFileClient.swift
//
//
//  Created by ockey12 on 2024/04/13.
//

import ComposableArchitecture
import SourceFileClient
import SwiftUI

@Reducer
public struct SourceFileClientDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var rootPathString: String
        var sourceFiles: IdentifiedArrayOf<SourceFile>

        public init(
            rootPathString: String,
            sourceFiles: IdentifiedArrayOf<SourceFile>
        ) {
            self.rootPathString = rootPathString
            self.sourceFiles = sourceFiles
        }
    }

    public enum Action: BindableAction {
        case getSourceFilesButtonTapped
        case sourceFileResponse(Result<IdentifiedArrayOf<SourceFile>, Error>)
        case selectButtonTapped(SourceFile)
        case binding(BindingAction<State>)
    }

    @Dependency(SourceFileClient.self) var sourceFileClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .getSourceFilesButtonTapped:
                return .run { [rootPathString = state.rootPathString] send in
                    #if DEBUG
                    let startTime = CFAbsoluteTimeGetCurrent()
                    #endif
                    if let derivedDataPath = getDerivedDataPath(for: rootPathString) {
                        print("DerivedData path: \(derivedDataPath)")
                    } else {
                        print("Failed to get the DerivedData path.")
                    }
                    #if DEBUG
                    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    print("TIME ELAPSED: \(timeElapsed)")
                    print("=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=")
                    #endif

                    await send(.sourceFileResponse(Result {
                        try await IdentifiedArray(
                            uniqueElements: sourceFileClient.getSourceFiles(
                                rootDirectoryPath: rootPathString,
                                ignoredDirectories: [".build", "DerivedData"]
                            )
                        )
                    }))
                }

            case let .sourceFileResponse(.success(sourceFiles)):
                state.sourceFiles = sourceFiles
                return .none

            case .sourceFileResponse(.failure):
                return .none

            case .selectButtonTapped:
                return .none

            case .binding:
                return .none
            }
        }
    }
}

public struct SourceFileClientDebugView: View {
    @Bindable public var store: StoreOf<SourceFileClientDebugger>

    public init(store: StoreOf<SourceFileClientDebugger>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Form {
                TextField("Project root path", text: $store.rootPathString)
                Button("Get Source Files") {
                    store.send(.getSourceFilesButtonTapped)
                }
            }

            ScrollView {
                ForEach(store.sourceFiles, id: \.path) { sourceFile in
                    DisclosureGroup(sourceFile.path) {
                        VStack(alignment: .leading) {
                            Button("Select") {
                                store.send(.selectButtonTapped(sourceFile))
                            }
                            HStack {
                                Text(sourceFile.content)
                                    .padding(.leading)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .background(.black)
                        }
                        .padding(.leading)
                    }
                }
            }
        }
    }
}

func getDerivedDataPath(for projectRootPath: String) -> String? {
    let task = Process()
    task.launchPath = "/usr/bin/xcodebuild"
    task.arguments = ["-project", projectRootPath, "-showBuildSettings"]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            if line.contains("BUILD_DIR = ") {
                var derivedDataPath = line.replacingOccurrences(of: "BUILD_DIR = ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                derivedDataPath = derivedDataPath.components(separatedBy: "/Build/")[0]
                return derivedDataPath
            }
        }
    }

    return nil
}
