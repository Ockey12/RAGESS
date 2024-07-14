//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/13
//  
//

import ComposableArchitecture
import SwiftUI
import XcodeObject

@Reducer
public struct CellReducer {
    @ObservableState
    public struct State: Identifiable {
        public var id: String {
            content.id
        }
        let content: Content
        var name: String {
            content.name
        }
        let leadingPadding: CGFloat
        var isExpanding: Bool
    }

    public enum Content {
        case directory(Directory)
        case sourceFile(SourceFile)

        var id: String {
            switch self {
            case let .directory(directory):
                directory.id
            case let .sourceFile(sourceFile):
                sourceFile.id
            }
        }

        var name: String {
            switch self {
            case let .directory(directory):
                directory.name
            case let .sourceFile(sourceFile):
                sourceFile.name
            }
        }
    }

    public enum Action {
        case expandButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .expandButtonTapped:
                state.isExpanding.toggle()
                return .none
            }
        }
    }
}

struct CellView: View {
    let store: StoreOf<CellReducer>

    init(store: StoreOf<CellReducer>) {
        self.store = store
    }

    var body: some View {
        HStack(spacing: 0) {
            if case .directory = store.content {
                Button(
                    action: {
                        store.send(.expandButtonTapped)
                    },
                    label: {
                        if store.isExpanding {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 8, height: 8)
                                .frame(width: 15, height: 15)
                        } else {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 8, height: 8)
                                .frame(width: 15, height: 15)
                        }
                    }
                )
                .buttonStyle(BorderlessButtonStyle())
            }

            switch store.content {
            case let .directory(directory):
                if directory.files.isEmpty,
                   directory.subDirectories.isEmpty {
                    Image(systemName: "folder.badge.gearshape")
                        .foregroundStyle(Color(red: 39 / 255, green: 185 / 255, blue: 1))
                } else {
                    Image(systemName: "folder.fill.badge.gearshape")
                        .foregroundStyle(Color(red: 39 / 255, green: 185 / 255, blue: 1))
                }
            case .sourceFile:
                Image(systemName: "swift")
                    .foregroundStyle(Color(red: 1, green: 120 / 255, blue: 67 / 255))
            }

            Text(store.name)
                .padding(.leading, 5)

            Spacer()
        } // HStack
        .frame(height: 20)
        .padding(.leading, store.leadingPadding)
    }
}

#Preview(traits: .fixedLayout(width: 800, height: 100)) {
    List {
        CellView(
            store: .init(
                initialState: CellReducer.State(
                    content: .directory(
                        Directory(path: "Project/Directory", subDirectories: [], files: [])
                    ),
                    leadingPadding: 0,
                    isExpanding: false
                ),
                reducer: {
                    CellReducer()
                }
            )
        )
        .listRowSeparator(.hidden)

        CellView(
            store: .init(
                initialState: CellReducer.State(
                    content: .directory(
                        Directory(path: "Project/Directory", subDirectories: [], files: [])
                    ),
                    leadingPadding: 0,
                    isExpanding: true
                ),
                reducer: {
                    CellReducer()
                }
            )
        )
        .listRowSeparator(.hidden)

        CellView(
            store: .init(
                initialState: CellReducer.State(
                    content: .directory(
                        Directory(
                            path: "Project/Directory",
                            subDirectories: [
                                Directory(
                                    path: "Project/Directory/Directory",
                                    subDirectories: [],
                                    files: []
                                )
                            ],
                            files: []
                        )
                    ),
                    leadingPadding: 0,
                    isExpanding: true
                ),
                reducer: {
                    CellReducer()
                }
            )
        )
        .listRowSeparator(.hidden)

        CellView(
            store: .init(
                initialState: CellReducer.State(
                    content: .sourceFile(
                        SourceFile(path: "Project/Directory/File.swift", content: "")
                    ),
                    leadingPadding: 0,
                    isExpanding: true
                ),
                reducer: {
                    CellReducer()
                }
            )
        )
        .listRowSeparator(.hidden)
    }
    .frame(width: 200, height: 200)
}
