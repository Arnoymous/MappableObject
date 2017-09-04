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

open class MappableObject: Object, Mappable {
    
    open class func jsonPrimaryKey() -> String? {
        return nil
    }
    
    open func mappingPrimaryKey(map: Map) { }
    
    open func mapping(map: Map) {
        self.validate(map: map)
        
        if type(of: self).hasPrimaryKey,
            let primaryKey = type(of: self).primaryKey(),
            let preferedPrimaryKey = type(of: self).preferredPrimaryKey {
            switch map.mappingType {
            case .toJSON:
                var value = self[primaryKey]
                value <- map[preferedPrimaryKey]
            case .fromJSON where self.realm == nil:
                self.mappingPrimaryKey(map: map)
            default:
                break
            }
        }
    }
    
    public var json: [String:Any] {
        var JSON = [String:Any]()
        try? self.update {
            JSON = $0.toJSON()
        }
        return JSON
    }
    
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
}
