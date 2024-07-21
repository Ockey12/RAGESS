//
//  TreeViewReducer.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import DeclarationObjectsClient
import Dependencies
import Foundation
import TypeDeclaration

@Reducer
public struct TreeViewReducer {
    public init() {}

    @ObservableState
    public struct State {
        public var rootObject: (any DeclarationObject)? {
            didSet {
                if let object = rootObject {
                    #if DEBUG
                        let rootNode = generateTree(rootObject: object, allDeclarationObjects: allDeclarationObjects)
                        print("printTree(parentNode: rootNode)")
                        if let rootNode {
                            printTree(parentNode: rootNode)
                        }
                    #endif
                }
            }
        }

        var nodes: IdentifiedArrayOf<NodeReducer.State> = []
        var allDeclarationObjects: [any DeclarationObject] = []

        public init(rootObject: (any TypeDeclaration)? = nil, allDeclarationObjects: [any DeclarationObject]) {
            self.rootObject = rootObject
            self.allDeclarationObjects = allDeclarationObjects
        }

        /// Return  a root node.
        func generateTree(
            rootObject: any DeclarationObject,
            allDeclarationObjects: [any DeclarationObject]
        ) -> NodeModel? {
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
                return nil
            }

            let rootNode = NodeModel(
                object: genericTypeObject,
                parentID: nil,
                allDeclarationObjects: allDeclarationObjects
            )
            var queue: [NodeModel] = [rootNode]
            var allNodes: [NodeModel] = [rootNode]
            var didVisitObjectsID: Set<UUID> = [rootNode.object.id]

            while !queue.isEmpty {
                let node = queue.removeFirst()
                let dependencies = node.object.objectsThatCallThisObject
                didVisitObjectsID.insert(node.object.id)

                for dependency in dependencies {
                    guard let callerObject = allDeclarationObjects.first(where: { $0.id == dependency.callerObject.rootObjectID }) else {
                        continue
                    }
                    guard node.object.id != callerObject.id else {
                        continue
                    }
                    guard !didVisitObjectsID.contains(callerObject.id) else {
                        continue
                    }
                    didVisitObjectsID.insert(callerObject.id)

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

                    let child = NodeModel(
                        object: genericTypeObject,
                        parentID: node.object.id,
                        allDeclarationObjects: allDeclarationObjects
                    )
                    queue.append(child)
                    allNodes.append(child)
                }
            } // while

            while allNodes.count > 1 {
                let child = allNodes.removeLast()

                guard let parentIndex = allNodes.firstIndex(where: { $0.id == child.parentID }) else {
                    #if DEBUG
                        print("ERROR: \(#file) - \(#function): Couldn't find parent node.")
                    #endif
                    break
                }

                allNodes[parentIndex].children.append(child)
            }

            return allNodes[0]
        }

        #if DEBUG
            func printTree(parentNode: NodeModel, level: Int = 0) {
                let indent = String(repeating: "  ", count: level)
                print("\(indent)\(parentNode.object.name), id: \(parentNode.id), parentID: \(parentNode.parentID)")

                for child in parentNode.children {
                    printTree(parentNode: child, level: level + 1)
                }
            }
        #endif
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
