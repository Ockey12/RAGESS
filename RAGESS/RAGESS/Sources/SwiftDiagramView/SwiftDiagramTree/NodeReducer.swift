//
//  NodeReducer.swift
//
//
//  Created by Ockey12 on 2024/07/19
//
//

import ComposableArchitecture
import DeclaredObject
import DependencyObject
import XcodeObject

@Reducer
public struct NodeReducer {
    public init() {}

    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: UUID {
            object.id
        }

        let object: DeclaredObject

        var header: HeaderReducer.State
        var details: IdentifiedArrayOf<DetailReducer.State>

        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let topLeadingPoint: CGPoint
        let subtreeTopLeadingPoint: CGPoint

        public init(
            object: DeclaredObject,
            rootDirectory: Directory,
            usrTable: [String: KeyPath<Directory, DeclaredObject>],
            dependencyObjects: [DependencyObject],
            topLeadingPoint: CGPoint,
            subtreeTopLeadingPoint: CGPoint
        ) {
            self.object = object
            self.topLeadingPoint = topLeadingPoint
            self.subtreeTopLeadingPoint = subtreeTopLeadingPoint

            let borderWidth = ComponentSizeValues.borderWidth
            let connectionHeight = ComponentSizeValues.connectionHeight
            let itemHeight = ComponentSizeValues.itemHeight
            let bottomPaddingForLastText = ComponentSizeValues.bottomPaddingForLastText
            let bottomPadding = ComponentSizeValues.bottomPaddingForLastText

            let abstractTypeDependencies = dependencyObjects.filteringAbstractTypeDependencies(concreteObject: object)
            let abstractObjects: [DeclaredObject] = abstractTypeDependencies.compactMap { dependency in
                guard let abstractObjectKeyPath = usrTable[dependency.calleeUSR] else {
                    return nil
                }
                return rootDirectory[keyPath: abstractObjectKeyPath]
            }

            let hasSuperClass: Bool = if object.kind == .class {
                abstractObjects.contains { $0.kind == .class }
            } else {
                false
            }

            let abstractProtocols = abstractObjects.filter { $0.kind == .protocol }

            // set bodyWidth and frameWidth
            var allAnnotatedDecl = [object.annotatedDecl ?? object.name]
            allAnnotatedDecl.append(contentsOf: abstractObjects.map { $0.annotatedDecl ?? $0.name })
            allAnnotatedDecl.append(contentsOf: object.initializers.map { $0.annotatedDecl ?? $0.name })
            allAnnotatedDecl.append(contentsOf: object.variables.map { $0.annotatedDecl ?? $0.name })
            allAnnotatedDecl.append(contentsOf: object.functions.map { $0.annotatedDecl ?? $0.name })
            allAnnotatedDecl.append(contentsOf: object.cases.map { $0.annotatedDecl ?? $0.name })
            let bodyWidth = max(
                calculateMaxTextWidth(allAnnotatedDecl),
                ComponentSizeValues.bodyMinWidth
            )
            frameWidth = bodyWidth
                + ComponentSizeValues.arrowTerminalWidth * 2
                + ComponentSizeValues.borderWidth

            // set header
            header = HeaderReducer.State(
                object: object,
                topLeadingPoint: topLeadingPoint,
                bodyWidth: bodyWidth
            )

            // set details
            var details: [DetailReducer.State] = []
            var frameBottomLeadingPoint = CGPoint(
                x: topLeadingPoint.x,
                y: topLeadingPoint.y
                + borderWidth / 2
                + itemHeight * 2
                + bottomPaddingForLastText
            )

            if hasSuperClass,
               let superClass = abstractObjects.first(where: { $0.kind == .class }) {
                details.append(
                    .init(
                        objects: [superClass],
                        kind: .superClass,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )

                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                    + connectionHeight
                    + itemHeight
                    + bottomPaddingForLastText
                )
            }

            if !abstractProtocols.isEmpty {
                let kind: DetailKind = if object.kind == .protocol {
                    .parentProtocol
                } else {
                    .protocolConformance
                }
                details.append(
                    .init(
                        objects: abstractProtocols,
                        kind: kind,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                    + connectionHeight
                    + itemHeight * CGFloat(abstractProtocols.count)
                    + bottomPaddingForLastText
                )
            }

            if !object.initializers.isEmpty {
                details.append(
                    .init(
                        objects: object.initializers,
                        kind: .initializers,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                    + connectionHeight
                    + itemHeight * CGFloat(object.initializers.count)
                    + bottomPaddingForLastText
                )
            }

            if !object.cases.isEmpty {
                details.append(
                    .init(
                        objects: object.cases,
                        kind: .case,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                    + connectionHeight
                    + itemHeight * CGFloat(object.cases.count)
                    + bottomPaddingForLastText
                )
            }

            if !object.variables.isEmpty {
                details.append(
                    .init(
                        objects: object.variables,
                        kind: .variables,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )
                frameBottomLeadingPoint = CGPoint(
                    x: frameBottomLeadingPoint.x,
                    y: frameBottomLeadingPoint.y
                    + connectionHeight
                    + itemHeight * CGFloat(object.variables.count)
                    + bottomPaddingForLastText
                )
            }

            if !object.functions.isEmpty {
                details.append(
                    .init(
                        objects: object.functions,
                        kind: .functions,
                        topLeadingPoint: frameBottomLeadingPoint,
                        frameWidth: bodyWidth
                    )
                )
            }

            self.details = .init(uniqueElements: details)

            // set frameHeight
            var frameHeight: CGFloat = itemHeight * 2 + bottomPadding
            if hasSuperClass {
                frameHeight += connectionHeight + itemHeight + bottomPadding
            }
            if !abstractProtocols.isEmpty {
                frameHeight += connectionHeight + itemHeight * CGFloat(abstractProtocols.count) + bottomPadding
            }
            if !object.initializers.isEmpty {
                frameHeight += connectionHeight + itemHeight * CGFloat(object.initializers.count) + bottomPadding
            }
            if !object.cases.isEmpty {
                frameHeight += connectionHeight + itemHeight * CGFloat(object.cases.count) + bottomPadding
            }
            if !object.variables.isEmpty {
                frameHeight += connectionHeight + itemHeight * CGFloat(object.variables.count) + bottomPadding
            }
            if !object.functions.isEmpty {
                frameHeight += connectionHeight + itemHeight * CGFloat(object.functions.count) + bottomPadding
            }
            frameHeight += connectionHeight + borderWidth

            self.frameHeight = frameHeight
        }
    }

    public enum Action {
        case header(HeaderReducer.Action)
        case details(IdentifiedActionOf<DetailReducer>)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.header, action: \.header) {
            HeaderReducer()
        }
        Reduce { _, _ in
            .none
        }
        .forEach(\.details, action: \.details) {
            DetailReducer()
        }
    }
}
