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
        let rootObject: (any DeclarationObject)?
        var nodes: IdentifiedArrayOf<NodeReducer.State>
        let allDeclarationObjects: [any DeclarationObject]
        public let frameWidth: CGFloat
        public let frameHeight: CGFloat

        public init(rootObject: (any DeclarationObject)? = nil, allDeclarationObjects: [any DeclarationObject]) {
            self.rootObject = rootObject
            self.allDeclarationObjects = allDeclarationObjects

            guard let rootObject else {
                nodes = []
                frameWidth = 0
                frameHeight = 0
                return
            }

            let rootNode = TreeGenerator.generateTree(rootObject: rootObject, allDeclarationObjects: allDeclarationObjects)

            guard let rootNode else {
                nodes = []
                frameWidth = 0
                frameHeight = 0
                return
            }
            #if DEBUG
                print("printTree(parentNode: rootNode)")
                TreeGenerator.printTree(parentNode: rootNode)
            #endif

            frameHeight = rootNode.subtreeHeight
            let nodesState = TreeGenerator.generateNodesState(rootNode: rootNode, allDeclarationObjects: allDeclarationObjects)
            frameWidth = nodesState.map { $0.topLeadingPoint.x + $0.frameWidth }.max() ?? 0
            nodes = .init(uniqueElements: nodesState)
            #if DEBUG
                for node in nodes {
                    print(node.object.name)
                    print("  topLeadingPoint: \(node.topLeadingPoint)")
                    print("  W: \(node.frameWidth), H: \(node.frameWidth)")
                }
                print("frameWidth: \(frameWidth)")
                print("frameHeight: \(frameHeight)")
            #endif
        }
    }

    public enum Action {
        case task
        case declarationObjectsClientResponse(Result<[any DeclarationObject], Error>)
        case nodes(IdentifiedActionOf<NodeReducer>)
    }

    @Dependency(DeclarationObjectsClient.self) var declarationObjectsClient

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .task:
                return .run { send in
                    await send(.declarationObjectsClientResponse(Result {
                        await declarationObjectsClient.get()
                    }))
                }

            case let .declarationObjectsClientResponse(.success(objects)):
//                state.allDeclarationObjects = objects
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

let verticalPadding: CGFloat = 500

private enum TreeGenerator {
    /// Return  a root node.
    static func generateTree(
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
        static func printTree(parentNode: NodeModel, level: Int = 0) {
            let indent = String(repeating: "  ", count: level)
            print("\(indent)\(parentNode.object.name), id: \(parentNode.id), parentID: \(parentNode.parentID)")

            for child in parentNode.children {
                printTree(parentNode: child, level: level + 1)
            }
        }
    #endif

    static func generateNodesState(
        rootNode: NodeModel,
        allDeclarationObjects: [any DeclarationObject]
    ) -> [NodeReducer.State] {
        var queue: [NodeModel] = [rootNode]
        var allNodes: [NodeModel] = [rootNode]
        let horizontalPadding: CGFloat = 1000

        while !queue.isEmpty {
            let node = queue.removeFirst()
            queue.append(contentsOf: node.children)
            allNodes.append(contentsOf: node.children)
        }

        var currentParentID = rootNode.id
        var currentSubtreeTopLeadingPoint = CGPoint(
            x: 0,
            y: 0
        )
        var nodesState: [NodeReducer.State] = []
        for node in allNodes {
            if node.id == rootNode.id {
                // root node
                nodesState.append(
                    NodeReducer.State(
                        object: node.object,
                        allDeclarationObjects: allDeclarationObjects,
                        topLeadingPoint: CGPoint(
                            x: 0,
                            y: node.subtreeHeight / 2 - node.frameHeight / 2
                        ),
                        subtreeTopLeadingPoint: CGPoint(x: 0, y: 0)
                    )
                )

                currentSubtreeTopLeadingPoint.x += node.frameWidth + horizontalPadding
                #if DEBUG
                    print("\nRoot Node")
                    print(node.object.name)
                    print("  topLeadingPoint: \(nodesState.last!.topLeadingPoint)")
                    print("  W: \(node.frameWidth), H: \(node.frameHeight)")
                    print("  State W: \(nodesState.last!.frameWidth), H: \(nodesState.last!.frameHeight)")
                    print("  subtreeHeight: \(node.subtreeHeight)\n")
                #endif
                continue
            } // if

            if currentParentID != node.parentID,
               let parentID = node.parentID {
                guard let parent = nodesState.first(where: { $0.id == parentID }) else {
                    #if DEBUG
                        print("ERROR: \(#file) - \(#function): Couldn't find parent node.")
                    #endif
                    break
                }
                currentParentID = parentID
                currentSubtreeTopLeadingPoint = CGPoint(
                    x: parent.topLeadingPoint.x + parent.frameWidth + horizontalPadding,
                    y: parent.subtreeTopLeadingPoint.y
                )
                print("parentID changed: \(parentID)")
                print("new currentBottomPoint: \(currentSubtreeTopLeadingPoint)\n")
            }

            nodesState.append(
                NodeReducer.State(
                    object: node.object,
                    allDeclarationObjects: allDeclarationObjects,
                    topLeadingPoint: CGPoint(
                        x: currentSubtreeTopLeadingPoint.x,
                        y: currentSubtreeTopLeadingPoint.y + node.subtreeHeight / 2 - node.frameHeight / 2
                    ),
                    subtreeTopLeadingPoint: currentSubtreeTopLeadingPoint
                )
            )

            #if DEBUG
                print(node.object.name)
                print("  topLeadingPoint: \(nodesState.last!.topLeadingPoint)")
                print("  W: \(node.frameWidth), H: \(node.frameHeight)")
                print("  State W: \(nodesState.last!.frameWidth), H: \(nodesState.last!.frameHeight)")
                print("  subtreeHeight: \(node.subtreeHeight)\n")
            #endif

            currentSubtreeTopLeadingPoint.y += node.subtreeHeight + verticalPadding
            print("increment currentBottomPoint.y: \(currentSubtreeTopLeadingPoint)\n")
        }

        print("end \(#function)\n")
        return nodesState
    }
}
