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
    left <- (right, MappableObjectTransform<T>(map: right))
}

public func <- <T: MappableObject>(left: inout T?, right: Map) {
    left <- (right, MappableObjectTransform<T>(map: right))
}

public func <- <T: MappableObject>(left: inout T!, right: Map) {
    left <- (right, MappableObjectTransform<T>(map: right))
}

public func <- <T: MappableObject>(left: List<T>, right: Map) {
    var list = [T]()
    switch right.mappingType {
    case .fromJSON where right.isKeyPresent:
        if let value: Any = right.value(),
            let _list = ListMappableObjectTransform<T>(map: right).transformFromJSON(value) {
            list.append(contentsOf: _list)
        }
        left.removeAll()
        left.append(objectsIn: list)
    case .toJSON:
        list.append(contentsOf: Array(left))
        list <- right
    default:
        break
    }
    list.removeAll()
}
