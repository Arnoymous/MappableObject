//
//  MappableObject.swift
//  Pods
//
//  Created by Arnaud Dorgans on 01/09/2017.
//
//

import UIKit
import Realm
import RealmSwift
import ObjectMapper

infix operator <-

public func <- <T: MappableObject>(left: T, right: Map) {
    mapObject(left, map: right)
}

public func <- <T: MappableObject>(left: inout T?, right: Map) {
    mapObject(left, map: right)
}

public func <- <T: MappableObject>(left: List<T>, right: Map) {
    var list = [T]()
    switch right.mappingType {
    case .fromJSON:
        if let value: Any = right.value(),
            let _list = ListMappableObjectTransform<T>(context: right.context).transformFromJSON(value) {
            list = Array(_list)
        }
        left.removeAll()
        left.append(objectsIn: list)
    case .toJSON:
        list.append(contentsOf: Array(left))
        list <- right
    }
    list.removeAll()
}

private func mapObject<T: MappableObject>(_ object: T?, map: Map) {
    var object = object
    object <- (map, MappableObjectTransform<T>(context: map.context))
}

open class MappableObject: Object, Mappable {
    
    public required init?(map: Map) {
        super.init()
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    public func mappingPrimaryKey(map: Map) { }
    
    public func mapping(map: Map) {
        if let primaryKey = type(of: self).primaryKey() {
            switch map.mappingType {
            case .toJSON:
                var value = self[primaryKey]
                value <- map[primaryKey]
            case .fromJSON:
                if self[primaryKey] == nil || self[primaryKey] is NSNull {
                    self.mappingPrimaryKey(map: map)
                }
            }
        }
    }
}

public class MappableObjectTransform<T: MappableObject>: TransformType {
    public typealias JSON = [String:Any]
    public typealias Object = T
    
    public var context: MapContext?
    
    public init(context: MapContext? = nil) {
        self.context = context
    }
    
    public func transformFromJSON(_ value: Any?) -> T? {
        if let JSON = value as? JSON {
            let realm = try! Realm()
            var _object: T?
            do {
                try realm.safeWrite {
                    if let primaryKey = T.primaryKey(),
                        let primaryValue = JSON[primaryKey] as? String,
                        let object = realm.object(ofType: T.self, forPrimaryKey: primaryValue) {
                        object.mapping(map: Map(mappingType: .fromJSON, JSON: JSON, context: context))
                        realm.add(object, update: true)
                        _object = object
                    } else {
                        _object = Mapper<T>(context: context).map(JSON: JSON)
                        if let object = _object {
                            realm.add(object)
                        }
                    }
                }
            } catch { }
            return _object
        }
        return nil
    }
    
    public func transformToJSON(_ value: T?) -> [String : Any]? {
        return value?.toJSON()
    }
}

public class ListMappableObjectTransform<T: MappableObject>: TransformType {
    public typealias JSON = [[String:Any]]
    public typealias Object = List<T>
    
    public var context: MapContext?
    
    public init(context: MapContext? = nil) {
        self.context = context
    }
    
    public func transformFromJSON(_ value: Any?) -> List<T>? {
        if let objects = value as? JSON {
            let list = List<T>()
            let items = objects.reduce([], { (result, JSON) -> [T] in
                var result = result
                if let object = MappableObjectTransform<T>(context: context).transformFromJSON(JSON) {
                    result.append(object)
                }
                return result
            })
            list.append(objectsIn: items)
            return list
        }
        return nil
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.map { $0.toJSON() }
    }
}

extension Realm {
    internal func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension Object {
    public static func object(forPrimaryKey primaryKey: String) -> Self? {
        let realm = try! Realm()
        return realm.object(ofType: self, forPrimaryKey: primaryKey)
    }
}
