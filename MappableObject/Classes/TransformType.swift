//
//  TransformType.swift
//  Pods
//
//  Created by Arnaud Dorgans on 02/09/2017.
//
//

import UIKit
import RealmSwift
import ObjectMapper

public class MappableObjectTransform<T: MappableObject>: TransformType {
    public typealias JSON = [String:Any]
    public typealias Object = T
    
    let context: RealmMapContext?
    
    public init(context: RealmMapContext? = nil) {
        self.context = context
    }
    
    internal convenience init(map: Map) {
        self.init(context: map.context as? RealmMapContext)
    }
    
    public func transformFromJSON(_ value: Any?) -> T? {
        if let JSON = value as? JSON {
            return RealmMapper.getOrCreate(fromJSON: JSON, context: context, realm: nil, options: nil)
        }
        return nil
    }
    
    public func transformToJSON(_ value: T?) -> [String : Any]? {
        return value?.json
    }
}

public class ListMappableObjectTransform<T: MappableObject>: TransformType {
    public typealias JSON = [[String:Any]]
    public typealias Object = List<T>
    
    public let context: RealmMapContext?
    
    public init(context: RealmMapContext? = nil) {
        self.context = context
    }
    
    internal convenience init(map: Map) {
        self.init(context: map.context as? RealmMapContext)
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
        return value?.map{ $0.json }
    }
}
