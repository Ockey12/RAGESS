//
//  CellView.swift
//
//
//  Created by Ockey12 on 2024/07/13
//
//

import ComposableArchitecture
import DeclarationObjectsClient
import Dependencies
import SwiftUI
import TypeDeclaration
import XcodeObject

@Reducer
public struct CellReducer {
//    @Reducer(state: .equatable)
    @Reducer
    public enum Destination {
        case popover(FileTreePopoverReducer)
    }

    @ObservableState
    public struct State: Identifiable {
        public var id: String {
            content.id
        }

        let content: Content
        var name: String {
            content.name
        }

        var children: IdentifiedArrayOf<Self>
        let leadingPadding: CGFloat
        var isExpanding: Bool
        @Presents var destination: Destination.State?

        public init(
            content: Content,
            leadingPadding: CGFloat,
            isExpanding: Bool = false
        ) {
            self.content = content
            switch content {
            case let .directory(directory):
                var children: [Self] = directory.files.map {
                    Self(
                        content: .sourceFile($0),
                        leadingPadding: leadingPadding,
                        isExpanding: isExpanding
                    )
                }
                children.append(contentsOf: directory.subDirectories.map {
                    Self(
                        content: .directory($0),
                        leadingPadding: leadingPadding,
                        isExpanding: isExpanding
                    )
                })
                self.children = .init(uniqueElements: children)

            case .sourceFile:
                children = []
            }

            self.leadingPadding = leadingPadding
            self.isExpanding = isExpanding
        }
    }

    @Dependency(DeclarationObjectsClient.self) var declarationObjectsClient

    public indirect enum Action {
        case expandButtonTapped
        case nameClicked
        case declarationObjectsResponse([any DeclarationObject])
        case children(IdentifiedActionOf<CellReducer>)
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)

        public enum Delegate {
            case childrenExpanded(content: Content, leadingPadding: CGFloat)
            case childrenCollapsed(content: Content)
            case nameClicked(Content)
            case popoverCellClicked(objectID: UUID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .expandButtonTapped:
                state.isExpanding.toggle()
                return .send(
                    state.isExpanding
                        ? .delegate(.childrenExpanded(
                            content: state.content,
                            leadingPadding: state.leadingPadding
                        ))
                        : .delegate(.childrenCollapsed(
                            content: state.content
                        )),
                    animation: .easeInOut
                )

            case .nameClicked:
                return .run { send in
                    let declarationObjects = await declarationObjectsClient.get()
                    await send(.declarationObjectsResponse(declarationObjects))
                }

            case let .declarationObjectsResponse(objects):
                state.destination = .popover(FileTreePopoverReducer.State(content: state.content, declarationObjects: objects))
                return .none

            case .children:
                return .none

            case let .destination(.presented(.popover(.delegate(.cellClicked(objectID: objectID))))):
                return .send(.delegate(.popoverCellClicked(objectID: objectID)))

            case .destination:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.children, action: \.children) {
            CellReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }
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

struct CellView: View {
    @Bindable var store: StoreOf<CellReducer>

    init(store: StoreOf<CellReducer>) {
        self.store = store
    }

    var body: some View {
        HStack(spacing: 0) {
            if case let .directory(directory) = store.content,
               !directory.files.isEmpty || !directory.subDirectories.isEmpty {
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

                // FIXME: Classify icons into directories, packages, and modules.
                if directory.files.isEmpty,
                   directory.subDirectories.isEmpty {
                    Image(systemName: "folder")
                        .foregroundStyle(Color(red: 39 / 255, green: 185 / 255, blue: 1))
                } else {
                    Image(systemName: "folder.fill")
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
        .onTapGesture {
            store.send(.nameClicked)
        }
        .popover(
            item: $store.scope(
                state: \.destination?.popover,
                action: \.destination.popover
            )
        ) { popoverStore in
            FileTreePopoverContent(store: popoverStore)
        }
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
