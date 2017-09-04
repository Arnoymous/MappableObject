//
//  Operators.swift
//  Pods
//
//  Created by Arnaud Dorgans on 02/09/2017.
//
//

import UIKit
import RealmSwift
import ObjectMapper

infix operator <-

public func <- <T: MappableObject>(left: inout T, right: Map) {
    left <- RealmMap(right)
}

public func <- <T: MappableObject>(left: inout T, right: RealmMap) {
    left <- (right.map, MappableObjectTransform<T>(map: right.map))
}

public func <- <T: MappableObject>(left: inout T?, right: Map) {
    left <- RealmMap(right)
}

public func <- <T: MappableObject>(left: inout T?, right: RealmMap) {
    left <- (right.map, MappableObjectTransform<T>(map: right.map))
}

public func <- <T: MappableObject>(left: inout T!, right: Map) {
    left <- RealmMap(right)
}

public func <- <T: MappableObject>(left: inout T!, right: RealmMap) {
    left <- (right.map, MappableObjectTransform<T>(map: right.map))
}

public func <- <T: MappableObject>(left: List<T>, right: Map) {
    left <- RealmMap(right)
}

public func <- <T: MappableObject>(left: List<T>, right: RealmMap) {
    var list = [T]()
    switch right.map.mappingType {
    case .fromJSON where right.map.isKeyPresent:
        if let value: Any = right.map.value(),
            let _list = ListMappableObjectTransform<T>(map: right.map).transformFromJSON(value) {
            list.append(contentsOf: _list)
        }
        left.removeAll()
        left.append(objectsIn: list)
    case .toJSON:
        list.append(contentsOf: Array(left))
        list <- right.map
    default:
        break
    }
    list.removeAll()
}
