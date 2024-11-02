//
//  TypeNestable.swift
//
//
//  Created by Ockey12 on 2024/05/19
//
//

public protocol TypeNestable: DeclarationObject {
    var nestingProtocols: [ProtocolObject] { get set }
    var nestingStructs: [StructObject] { get set }
    var nestingClasses: [ClassObject] { get set }
    var nestingEnums: [EnumObject] { get set }
    var nestingActors: [ActorObject] { get set }
}
