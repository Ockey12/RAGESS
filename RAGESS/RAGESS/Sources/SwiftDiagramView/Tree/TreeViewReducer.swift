//
//  File.swift
//  
//  
//  Created by Ockey12 on 2024/07/19
//  
//

import ComposableArchitecture
import DeclarationObjectsClient
import Dependencies
import TypeDeclaration

@Reducer
public struct TreeViewReducer {
    public init() {}

    @ObservableState
    public struct State {
        var rootObject: (any DeclarationObject)? {
            didSet {
                if let object = rootObject {
                    nodes = generateTree(rootObject: object, allDeclarationObjects: allDeclarationObjects)
                }
            }
        }
        var nodes: IdentifiedArrayOf<NodeReducer.State> = []
        var allDeclarationObjects: [any DeclarationObject] = []

        public init(rootObject: (any TypeDeclaration)? = nil) {
            self.rootObject = rootObject
        }

        func generateTree(
            rootObject: any DeclarationObject,
            allDeclarationObjects: [any DeclarationObject]
        ) -> IdentifiedArrayOf<NodeReducer.State> {
            let genericTypeObject: GenericTypeObject
            switch rootObject {
            case let structObject as StructObject:
                genericTypeObject = .struct(structObject)
            case let classObject as ClassObject:
                genericTypeObject = .class(classObject)
            case let enumObject as EnumObject:
                genericTypeObject = .enum(enumObject)
            case let protocolObject as ProtocolObject:
                genericTypeObject = .protocol(protocolObject)
            default:
#if DEBUG
                print("ERROR: \(#file) - \(#function): Cannot cast \(rootObject.name) to Type.")
#endif
                return []
            }
            let rootNode = extractChildren(parentNode: NodeModel(object: genericTypeObject), allDeclarationObjects: allDeclarationObjects)

#if DEBUG
            dump(rootNode)
#endif

            return []
        }

        func extractChildren(
            parentNode: NodeModel,
            allDeclarationObjects: [any DeclarationObject]
        ) -> [NodeModel] {
            let dependencies = parentNode.object.objectsThatCallThisObject
            var children: [NodeModel] = []

            for dependency in dependencies {
                guard let callerObject = allDeclarationObjects.first(where: {$0.id == dependency.callerObject.rootObjectID}) else {
                    continue
                }
                let genericTypeObject: GenericTypeObject
                switch callerObject {
                case let structObject as StructObject:
                    genericTypeObject = .struct(structObject)
                case let classObject as ClassObject:
                    genericTypeObject = .class(classObject)
                case let enumObject as EnumObject:
                    genericTypeObject = .enum(enumObject)
                case let protocolObject as ProtocolObject:
                    genericTypeObject = .protocol(protocolObject)
                default:
                    continue
                }
                var child = NodeModel(object: genericTypeObject)
                child.children = extractChildren(parentNode: child, allDeclarationObjects: allDeclarationObjects)
                children.append(child)
            }

            return children
        }
    }

    public enum Action {
        case task
        case declarationObjectsClientResponse(Result<[any DeclarationObject], Error>)
        case nodes(IdentifiedActionOf<NodeReducer>)
    }

    @Dependency(DeclarationObjectsClient.self) var declarationObjectsClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.declarationObjectsClientResponse(Result {
                        await declarationObjectsClient.get()
                    }))
                }

            case let .declarationObjectsClientResponse(.success(objects)):
                state.allDeclarationObjects = objects
                return .none

            case let .declarationObjectsClientResponse(.failure(error)):
                print(error)
                return .none

            case .nodes:
                return .none
            }
        }
        .forEach(\.nodes, action: \.nodes) {
            NodeReducer()
        }
    }
}

