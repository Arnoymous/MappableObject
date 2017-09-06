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
        if let objects = Mapper<T>(context: context).mapArray(JSONObject: value) {
            let list = List<T>()
            list.append(objectsIn: objects)
            return list
        }
        return nil
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        if let list = value {
            return Mapper<T>(context: context).toJSONArray(Array(list))
        }
        return nil
    }
}
