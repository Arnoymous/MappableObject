//
//  Mapper.swift
//  Pods
//
//  Created by Arnaud Dorgans on 04/09/2017.
//
//

import UIKit
import ObjectMapper
import RealmSwift

public class RealmMapper {
    
    public static func update<T: MappableObject>(_ object: T, fromJSON JSON: [String:Any], context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) throws {
        try update(object, fromJSONObject: JSON, context: context, realm: realm, options: options)
    }
    
    public static func update<T: MappableObject>(_ object: T, fromJSONObject JSONObject: Any?, context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) throws {
        try object.update{
            _ = Mapper(context: RealmMapContext.from(context: context, realm: realm ?? $0.realm, options: options)).map(JSONObject: JSONObject, toObject: $0)
        }
    }
    
    public static func getOrCreate<T: MappableObject>(_ type: T.Type? = nil, forPrimaryKey primaryKey: String, realm: Realm?, options: RealmMapOptions?) -> T? {
        if T.hasPrimaryKey,
            let preferedPrimaryKey = T.preferredPrimaryKey {
            return getOrCreate(type, fromJSON: [preferedPrimaryKey: primaryKey], context: nil, realm: realm, options: options)
        }
        return nil
    }
    
    public static func getOrCreate<T: MappableObject>(_ type: T.Type? = nil, fromJSON JSON: [String:Any], context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) -> T? {
        return getOrCreate(type, fromJSONObject: JSON, context: context, realm: realm, options: options)
    }
    
    public static func getOrCreate<T: MappableObject>(_ type: T.Type? = nil, fromJSONObject JSONObject: Any?, context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) -> T? {
        
        let context = RealmMapContext.from(context: context, realm: realm, options: options)
        let primaryKey = T.primaryKey()
        let preferredPrimaryKey = T.preferredPrimaryKey
        let sync = context.options.contains(.sync)
        var object: T?
        do {
            let realm = try context.realm ?? Realm()
            try realm.safeWrite {
                if T.hasPrimaryKey,
                    sync,
                    let preferredPrimaryKey = preferredPrimaryKey,
                    let primaryValue = (JSONObject as? [String:Any])?[preferredPrimaryKey],
                    let savedObject = realm.object(ofType: T.self, forPrimaryKey: primaryValue) {
                    object = savedObject
                }
                if let object = object {
                    try object.update(fromJSONObject: JSONObject, context: context)
                } else {
                    object = Mapper<T>(context: context).map(JSONObject: JSONObject)
                }
                if sync {
                    if T.hasPrimaryKey,
                        let primaryKey = primaryKey,
                        let preferredPrimaryKey = preferredPrimaryKey, object?[primaryKey] == nil {
                        print("WARNING: '\(T.self)' object can't be saved: primaryKey '\(preferredPrimaryKey)' is needed")
                    } else if let object = object {
                        realm.add(object, update: T.hasPrimaryKey)
                    }
                }
            }
        } catch { }
        return object
    }
    
    public static func getOrCreateList<T: MappableObject>(_ type: T.Type? = nil, fromJSON JSON: [[String:Any]], context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) -> List<T>? {
        return getOrCreateList(type, fromJSONObject: JSON, context: context, realm: realm, options: options)
    }
    
    public static func getOrCreateList<T: MappableObject>(_ type: T.Type? = nil, fromJSONObject JSONObject: Any?, context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) -> List<T>? {
        return ListMappableObjectTransform<T>(context: RealmMapContext.from(context: context, realm: realm, options: options)).transformFromJSON(JSONObject)
    }

}

extension BaseMappable where Self: MappableObject {
    
    internal static var hasPrimaryKey: Bool {
        return self.primaryKey() != nil
    }
    
    internal static var preferredPrimaryKey: String? {
        return self.jsonPrimaryKey() ?? self.primaryKey()
    }
    
    public func update(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil) throws {
        try update(fromJSONObject: JSON, context: context, realm: realm)
    }
    
    public func update(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) throws {
        try update(fromJSONObject: JSON, context: context, realm: realm, options: options)
    }
    
    public func update(fromJSONObject JSONObject: Any?, context: RealmMapContext? = nil, realm: Realm? = nil) throws {
        try RealmMapper.update(self, fromJSONObject: JSONObject, context: context, realm: realm, options: nil)
    }
    
    public func update(fromJSONObject JSONObject: Any?, context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) throws {
        try RealmMapper.update(self, fromJSONObject: JSONObject, context: context, realm: realm, options: options)
    }
    
    public static func getOrCreate(forPrimaryKey primaryKey: String, realm: Realm? = nil) -> Self? {
        return getOrCreate(forPrimaryKey: primaryKey, realm: realm, options: .sync)
    }
    
    public static func getOrCreate(forPrimaryKey primaryKey: String, realm: Realm? = nil, options: RealmMapOptions) -> Self? {
        return RealmMapper.getOrCreate(forPrimaryKey: primaryKey, realm: realm, options: options)
    }
    
    public static func getOrCreate(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil) -> Self? {
        return getOrCreate(fromJSONObject: JSON, context: context, realm: realm)
    }
    
    public static func getOrCreate(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) -> Self? {
        return getOrCreate(fromJSONObject: JSON, context: context, realm: realm, options: options)
    }
    
    public static func getOrCreate(fromJSONObject JSONObject: Any?, context: RealmMapContext? = nil, realm: Realm? = nil) -> Self? {
        return RealmMapper.getOrCreate(fromJSONObject: JSONObject, context: context, realm: realm, options: context == nil ? RealmMapOptions.sync : nil)
    }
    public static func getOrCreate(fromJSONObject JSONObject: Any?, context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) -> Self? {
        return RealmMapper.getOrCreate(fromJSONObject: JSONObject, context: context, realm: realm, options: options)
    }
    
    internal func validate(map: Map) {
        if map.mappingType == .fromJSON, !(map.context is RealmMapContext) {
            print("WARNING: 'MappableObject' needs custom transforms, be sure to use RealmMap()")
            map.context = RealmMapContext()
        }
    }
}
