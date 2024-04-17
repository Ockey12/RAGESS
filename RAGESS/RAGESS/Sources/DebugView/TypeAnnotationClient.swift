//
//  TypeAnnotationClient.swift
//
//
//  Created by ockey12 on 2024/04/16.
//

import ComposableArchitecture
import SourceFileClient
import SwiftUI
import TypeAnnotationClient

@Reducer
public struct TypeAnnotationDebugger {
    public init() {}

    @ObservableState
    public struct State {
        var sourceFile: SourceFile
        var typeAnnotatedCode: String

        public init(sourceFile: SourceFile, typeAnnotatedCode: String) {
            self.sourceFile = sourceFile
            self.typeAnnotatedCode = typeAnnotatedCode
        }
    }

    public enum Action {
        case setTypeAnnotationsTapped
        case setTypeAnnotationsResponse(Result<String, Error>)
    }

    @Dependency(TypeAnnotationClient.self) var typeAnnotationClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setTypeAnnotationsTapped:
                return .run { [sourceFile = state.sourceFile] send in
                    await send(.setTypeAnnotationsResponse(Result {
                        try await typeAnnotationClient.setTypeAnnotations(sourceFile: sourceFile)
                    }))
                }

            case let .setTypeAnnotationsResponse(.success(typeAnnotatedCode)):
                state.typeAnnotatedCode = typeAnnotatedCode
                return .none

            case let .setTypeAnnotationsResponse(.failure(error)):
                return .none
            }
        }
    }
}

public struct TypeAnnotationDebugView: View {
    @Bindable public var store: StoreOf<TypeAnnotationDebugger>

    public init(store: StoreOf<TypeAnnotationDebugger>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    Text("File Path: \(store.sourceFile.path)")
                    Text(store.sourceFile.content)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.black)
                        .padding(.leading)
                    Button("Set Type Annotations") {
                        store.send(.setTypeAnnotationsTapped)
                    }
                    Text(store.typeAnnotatedCode)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.black)
                        .padding(.leading)
                }
                Spacer()
            }
        }
    }
}
