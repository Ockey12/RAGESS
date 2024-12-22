//
//  Array+filtering.swift
//
//
//  Created by Ockey12 on 2024/12/03
//
//

import DeclaredObject

public extension Array where Element == DependencyObject {
    func filteringWhereCallee(_ declaredObject: DeclaredObject) -> [DependencyObject] {
        let usrSet = Set(declaredObject.descendantsUSRs)
        return filter { dependency in
            usrSet.contains(dependency.calleeUSR)
        }
    }

    func filteringWhereCaller(_ declaredObject: DeclaredObject) -> [DependencyObject] {
        let usrSet = Set(declaredObject.usrs)

        return filter { dependency in
            guard let callerFirstUSR = dependency.callerUSRs.first else {
                return false
            }
            return usrSet.contains(callerFirstUSR)
        }
    }

    func filteringAbstractTypeDependencies(concreteObject: DeclaredObject) -> [DependencyObject] {
        filteringWhereCaller(concreteObject).filter { $0.roles.contains(.baseOf) }
    }
}
