//
//  Mapper.swift
//  Pods
//
//  Created by Arnaud Dorgans on 04/09/2017.
//
//

import UIKit
import ObjectMapper
import Realm
import RealmSwift

internal class RealmMapper<T: MappableObject> {
    
    var context: RealmMapContext?
    var realm: Realm?
    var shouldIncludeNilValues: Bool
    
    init(context: RealmMapContext? = nil, realm: Realm? = nil, shouldIncludeNilValues: Bool = false) {
        self.context = context
        self.realm = realm
        self.shouldIncludeNilValues = shouldIncludeNilValues
    }
    
    convenience init(map: Map) {
        self.init(context: map.context as? RealmMapContext, realm: nil, shouldIncludeNilValues: map.shouldIncludeNilValues)
    }
    
    func map(JSONObject: Any?, options: RealmMapOptions? = nil) throws -> T? {
        let context = RealmMapContext.from(object: nil, context: self.context, realm: self.realm, options: options)
        self.context = context
        let realm = try context.realm ?? Realm()
        self.realm = realm
        let JSONObject = self.jsonObject(fromJSONObject: JSONObject, context: context)
        
        let preferredPrimaryKey = T.preferredPrimaryKey
        let sync = context.options.contains(.sync)
        let copy = context.options.contains(.copy)
        var object: T?
        try realm.safeWrite {
            if T.hasPrimaryKey,
                sync,
                let preferredPrimaryKey = preferredPrimaryKey,
                let primaryValue = (JSONObject as? [String:Any])?[preferredPrimaryKey],
                let savedObject = realm.object(ofType: T.self, forPrimaryKey: primaryValue) {
                if !copy {
                    object = savedObject
                } else {
                    object = T(value: savedObject, schema: RLMSchema.partialShared())
                }
            }
            if let _object = object ?? T(map: self.map(fromJSONObject: JSONObject, context: context)) {
                _ = Mapper<T>(context: self.context).map(JSONObject: JSONObject, toObject: _object)
                if sync && !copy {
                    realm.add(_object, update: T.hasPrimaryKey)
                }
                object = _object
            }
        }
        return object
    }
    
    private func map(fromJSONObject JSONObject: Any?, context: RealmMapContext) -> Map {
        return Map(mappingType: .fromJSON, JSON: (JSONObject as? [String:Any]) ?? [:], context: context, shouldIncludeNilValues: false)
    }
    
    private func jsonObject(fromJSONObject JSONObject: Any?, context: RealmMapContext) -> Any? {
        if context.options.contains(.override) {
            var JSON = T().toJSON(shouldIncludeNilValues: true)
            if var _JSON = JSONObject as? [String:Any] {
                JSON.map{ $0.key }
                    .filter{_JSON[$0] != nil}
                    .forEach{ key in
                        JSON[key] = _JSON[key]
                    }
            }
            return JSON
        }
        return JSONObject
    }
}

extension Mapper where N: MappableObject {
    public convenience init(context: RealmMapContext? = nil, realm: Realm?, shouldIncludeNilValues: Bool = false) {
        self.init(context: context, realm: realm, options: nil, shouldIncludeNilValues: shouldIncludeNilValues)
    }
    
    public convenience init(context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions, shouldIncludeNilValues: Bool = false) {
        self.init(context: context, realm: realm, options: options as RealmMapOptions?, shouldIncludeNilValues: shouldIncludeNilValues)
    }
    
    private convenience init(context: RealmMapContext?, realm: Realm?, options: RealmMapOptions?, shouldIncludeNilValues: Bool = false) {
        self.init(context: RealmMapContext.from(context: context, realm: realm, options: options) as MapContext, shouldIncludeNilValues: shouldIncludeNilValues)
    }
}
