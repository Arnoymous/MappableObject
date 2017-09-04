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

internal class RealmMapper {
    
    static func update<T: MappableObject>(_ object: T, fromJSON JSON: [String:Any], context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) throws {
        try object.update{
            _ = Mapper(context: RealmMapContext.from(context: context, realm: realm ?? $0.realm, options: options)).map(JSON: JSON, toObject: $0)
        }
    }
    
    static func getOrCreate<T: MappableObject>(_ type: T.Type? = nil, forPrimaryKey primaryKey: String, realm: Realm?, options: RealmMapOptions?) -> T? {
        if T.hasPrimaryKey,
            let preferedPrimaryKey = T.preferredPrimaryKey {
            return getOrCreate(type, fromJSON: [preferedPrimaryKey: primaryKey], context: nil, realm: realm, options: options)
        }
        return nil
    }
    
    static func getOrCreate<T: MappableObject>(_ type: T.Type? = nil, fromJSON JSON: [String:Any], context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?) -> T? {
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
                    let primaryValue = JSON[preferredPrimaryKey],
                    let savedObject = realm.object(ofType: T.self, forPrimaryKey: primaryValue) {
                    object = savedObject
                }
                if let object = object {
                    try object.update(fromJSON: JSON, context: context)
                } else {
                    object = Mapper<T>(context: context).map(JSON: JSON)
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
}

extension BaseMappable where Self: MappableObject {
    
    internal static var hasPrimaryKey: Bool {
        return self.primaryKey() != nil
    }
    
    internal static var preferredPrimaryKey: String? {
        return self.jsonPrimaryKey() ?? self.primaryKey()
    }
    
    public func update(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil) throws {
        try RealmMapper.update(self, fromJSON: JSON, context: context, realm: realm, options: nil)
    }
    
    public func update(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) throws {
        try RealmMapper.update(self, fromJSON: JSON, context: context, realm: realm, options: options)
    }
    
    public static func getOrCreate(forPrimaryKey primaryKey: String, realm: Realm? = nil) -> Self? {
        return RealmMapper.getOrCreate(forPrimaryKey: primaryKey, realm: realm, options: .sync)
    }
    
    public static func getOrCreate(forPrimaryKey primaryKey: String, realm: Realm? = nil, options: RealmMapOptions) -> Self? {
        return RealmMapper.getOrCreate(forPrimaryKey: primaryKey, realm: realm, options: options)
    }
    
    public static func getOrCreate(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil) -> Self? {
        return RealmMapper.getOrCreate(fromJSON: JSON, context: context, realm: realm, options: context == nil ? RealmMapOptions.sync : nil)
    }
    
    public static func getOrCreate(fromJSON JSON: [String:Any], context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions) -> Self? {
        return RealmMapper.getOrCreate(fromJSON: JSON, context: context, realm: realm, options: options)
    }
    
    internal func validate(map: Map) {
        if map.mappingType == .fromJSON, !(map.context is RealmMapContext) {
            print("WARNING: 'MappableObject' needs custom transforms, be sure to use RealmMap()")
            map.context = RealmMapContext()
        }
    }
}
