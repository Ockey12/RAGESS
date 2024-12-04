//
//  SwiftDiagramTreeViewReducer.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import DeclaredObject
import DependencyObject
import Foundation
import XcodeObject

@Reducer
public struct SwiftDiagramTreeViewReducer {
    public init() {}

    @ObservableState
    public struct State {
        var nodes: IdentifiedArrayOf<NodeReducer.State>
        var arrows: IdentifiedArrayOf<ArrowViewReducer.State>
        public let frameWidth: CGFloat
        public let frameHeight: CGFloat

        public init(
            rootObjectKeyPath: KeyPath<Directory, DeclaredObject>? = nil,
            rootDirectory: Directory,
            usrTable: [String: KeyPath<Directory, DeclaredObject>],
            dependencyObjects: [DependencyObject]
        ) {
            guard let rootObjectKeyPath,
                  let rootNode = TreeGenerator.generate(
                    rootDirectory: rootDirectory,
                    rootObjectKeyPath: rootObjectKeyPath,
                    usrTable: usrTable,
                    dependencyObjects: dependencyObjects
                  )
            else {
                nodes = []
                arrows = []
                frameWidth = 0
                frameHeight = 0
                return
            }

            frameHeight = rootNode.subtreeHeight
            let nodeStates = TreeGenerator.generateNodeStates(
                rootNode: rootNode,
                rootDirectory: rootDirectory,
                usrTable: usrTable,
                dependencyObjects: dependencyObjects
            )
            frameWidth = nodeStates.map { $0.topLeadingPoint.x + $0.frameWidth }.max() ?? 0
            nodes = .init(uniqueElements: nodeStates)
            let arrowsState = ArrowsStateGenerator.generate(
                nodes: nodeStates,
                rootDirectory: rootDirectory,
                usrTable: usrTable,
                dependencyObjects: dependencyObjects
            )
            arrows = .init(uniqueElements: arrowsState)
        }
    }

    public enum Action {
        case nodes(IdentifiedActionOf<NodeReducer>)
        case arrows(IdentifiedActionOf<ArrowViewReducer>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .nodes:
                return .none

            case .arrows:
                return .none
            }
        }
        .forEach(\.nodes, action: \.nodes) {
            NodeReducer()
        }
        .forEach(\.arrows, action: \.arrows) {
            ArrowViewReducer()
        }
    }
}

let verticalPadding: CGFloat = 500

extension Directory {
    func findRootTypeObject(
        targetKeyPath: KeyPath<Directory, DeclaredObject>,
        usrTable: [String: KeyPath<Directory, DeclaredObject>]
    ) -> DeclaredObject? {
        var object = self[keyPath: targetKeyPath]

        while true {
            switch object.kind {
            case .struct, .class, .enum, .protocol, .actor:
                return object
            case .initializer, .variable, .function, .case:
                guard let parentUSR = object.parentUSRs.first,
                      let parentKeyPath = usrTable[parentUSR]
                else {
                    return nil
                }
                object = self[keyPath: parentKeyPath]
            }
        }
    }
}

private enum TreeGenerator {
    private static func convertToNodeModel(
        from declaredObject: DeclaredObject,
        rootDirectory: Directory,
        usrTable: [String: KeyPath<Directory, DeclaredObject>],
        dependencyObjects: [DependencyObject],
        parentID: UUID?
    ) -> NodeModel {
        let callerDependencies = dependencyObjects.filteringWhereCaller(declaredObject)
        let baseOfs = callerDependencies.filter { $0.roles.contains(.baseOf) }

        let baseObjects: [DeclaredObject] = baseOfs.compactMap { dependency in
            guard let calleeUSRKeyPath = usrTable[dependency.calleeUSR] else {
                return nil
            }
            return rootDirectory[keyPath: calleeUSRKeyPath]
        }

        let hasSuperClass: Bool = baseObjects.contains(where: { $0.kind == .class })

        let numberOfParentProtocols: Int = {
            if declaredObject.kind == .protocol {
                return baseObjects.filter { $0.kind == .protocol }.count
            } else {
                return 0
            }
        }()

        let numberOfConformances: Int = {
            if declaredObject.kind == .protocol {
                return 0
            } else {
                return baseObjects.filter { $0.kind == .protocol }.count
            }
        }()

        return NodeModel(
            object: declaredObject,
            parentID: parentID,
            hasSuperClass: hasSuperClass,
            numberOfParentProtocols: numberOfParentProtocols,
            numberOfConformances: numberOfConformances
        )
    }

    /// Return  a root node.
    static func generate(
        rootDirectory: Directory,
        rootObjectKeyPath: KeyPath<Directory, DeclaredObject>,
        usrTable: [String: KeyPath<Directory, DeclaredObject>],
        dependencyObjects: [DependencyObject]
    ) -> NodeModel? {
        let rootObject = rootDirectory[keyPath: rootObjectKeyPath]

        let rootNode = Self.convertToNodeModel(
            from: rootObject,
            rootDirectory: rootDirectory,
            usrTable: usrTable,
            dependencyObjects: dependencyObjects,
            parentID: nil
        )

        var queue: [NodeModel] = [rootNode]
        var allNodes: [NodeModel] = [rootNode]
        var didVisitObjectsID: Set<UUID> = [rootNode.object.id]

        while !queue.isEmpty {
            let node = queue.removeFirst()
            let dependencies = dependencyObjects.filteringWhereCallee(node.object)
            didVisitObjectsID.insert(node.object.id)

            for dependency in dependencies {
                guard let callerUSR = dependency.callerUSRs.first,
                      let callerKeyPath = usrTable[callerUSR]
                else {
                    continue
                }

                let callerRootObject = rootDirectory.findRootTypeObject(
                    targetKeyPath: callerKeyPath,
                    usrTable: usrTable
                )
                guard let callerRootObject,
                      node.object.id != callerRootObject.id,
                      !didVisitObjectsID.contains(callerRootObject.id)
                else {
                    continue
                }

                didVisitObjectsID.insert(callerRootObject.id)

                let child = Self.convertToNodeModel(
                    from: callerRootObject,
                    rootDirectory: rootDirectory,
                    usrTable: usrTable,
                    dependencyObjects: dependencyObjects,
                    parentID: node.object.id
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
            print("\(indent)\(parentNode.object.name), id: \(parentNode.id), parentID: \(parentNode.parentID?.uuidString ?? "nil")")

            for child in parentNode.children {
                printTree(parentNode: child, level: level + 1)
            }
        }
    #endif

    static func generateNodeStates(
        rootNode: NodeModel,
        rootDirectory: Directory,
        usrTable: [String: KeyPath<Directory, DeclaredObject>],
        dependencyObjects: [DependencyObject]
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
        var nodeStates: [NodeReducer.State] = []
        for node in allNodes {
            if node.id == rootNode.id {
                // root node
                nodeStates.append(
                    .init(
                        object: node.object,
                        rootDirectory: rootDirectory,
                        usrTable: usrTable,
                        dependencyObjects: dependencyObjects,
                        topLeadingPoint: CGPoint(
                            x: 0,
                            y: node.subtreeHeight / 2 - node.frameHeight / 2
                        ),
                        subtreeTopLeadingPoint: CGPoint(x: 0, y: 0)
                    )
                )
                currentSubtreeTopLeadingPoint.x += node.frameWidth + horizontalPadding
                continue
            }

            if currentParentID != node.parentID,
               let parentID = node.parentID {
                guard let parent = nodeStates.first(where: { $0.id == parentID }) else {
                    break
                }
                currentParentID = parentID
                currentSubtreeTopLeadingPoint = CGPoint(
                    x: parent.topLeadingPoint.x + parent.frameWidth + horizontalPadding,
                    y: parent.subtreeTopLeadingPoint.y
                )
            }

            nodeStates.append(
                .init(
                    object: node.object,
                    rootDirectory: rootDirectory,
                    usrTable: usrTable,
                    dependencyObjects: dependencyObjects,
                    topLeadingPoint: CGPoint(
                        x: currentSubtreeTopLeadingPoint.x,
                        y: currentSubtreeTopLeadingPoint.y + node.subtreeHeight / 2 - node.frameHeight / 2
                    ),
                    subtreeTopLeadingPoint: currentSubtreeTopLeadingPoint
                )
            )

            currentSubtreeTopLeadingPoint.y += node.subtreeHeight + verticalPadding
        }

        return nodeStates
    }
}

private enum ArrowsStateGenerator {
    static func generate(
        nodes: [NodeReducer.State],
        rootDirectory: Directory,
        usrTable: [String: KeyPath<Directory, DeclaredObject>],
        dependencyObjects: [DependencyObject]
    ) -> [ArrowViewReducer.State] {
        var arrowStates: [ArrowViewReducer.State] = []

        for node in nodes {
            let calleeDependencies = dependencyObjects.filteringWhereCallee(node.object)
            for dependency in calleeDependencies {
                guard let calleeKeyPath = usrTable[dependency.calleeUSR],
                      let callerUSR = dependency.callerUSRs.first,
                      let callerKeyPath = usrTable[callerUSR],
                      rootDirectory.findRootTypeObject(targetKeyPath: calleeKeyPath, usrTable: usrTable)
                      != rootDirectory.findRootTypeObject(targetKeyPath: callerKeyPath, usrTable: usrTable)
                else {
                    continue
                }

                // set start point coordinate
                var leadingStartPoint: CGPoint = .zero
                var trailingStartPoint: CGPoint = .zero
                if node.object.usrs.contains(dependency.calleeUSR) {
                    // This object itself is referenced, so the header becomes the starting point of the arrow.
                    leadingStartPoint = node.header.leadingArrowTerminalPoint
                    trailingStartPoint = node.header.trailingArrowTerminalPoint
                } else {
                    details: for detail in node.details {
                        for text in detail.texts {
                            if text.object.usrs.contains(dependency.calleeUSR) {
                                leadingStartPoint = text.leadingArrowTerminalPoint
                                trailingStartPoint = text.trailingArrowTerminalPoint
                                break details
                            }
                        }
                    }
                }

                // set end point coordinate
                var leadingEndPoint: CGPoint = .zero
                var trailingEndPoint: CGPoint = .zero
                guard let caller = nodes.first(where: { $0.object.descendantsUSRs.contains(dependency.callerUSRs) }) else {
                    assertionFailure()
                    continue
                }
                details: for detail in caller.details {
                    for text in detail.texts {
                        if text.object.descendantsUSRs.contains(dependency.callerUSRs) {
                            leadingEndPoint = text.leadingArrowTerminalPoint
                            trailingEndPoint = text.trailingArrowTerminalPoint
                            break details
                        }
                    }
                }
                arrowStates.append(
                    .init(
                        dependency: dependency,
                        leadingStartPoint: leadingStartPoint,
                        trailingStartPoint: trailingStartPoint,
                        leadingEndPoint: leadingEndPoint,
                        trailingEndPoint: trailingEndPoint
                    )
                )
            } // for dependency
        } // for node

        return arrowStates
    }
}
