//
//  Helpers.swift
//  Pods
//
//  Created by Arnaud Dorgans on 02/09/2017.
//
//

import UIKit
import ObjectMapper
import RealmSwift

extension Realm {
    internal func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension ThreadConfined where Self: MappableObject {
    internal func update(realm: Realm? = nil, block: (Self)->Void) throws {
        if self.isSync {
            try ((realm ?? self.realm) ?? Realm()).safeWrite{
                block(self)
            }
        } else {
            block(self)
        }
    }
}

extension BaseMappable where Self: MappableObject {
    internal static var hasPrimaryKey: Bool {
        return preferredPrimaryKey != nil
    }
    
    internal static var preferredPrimaryKey: String? {
        if let primaryKey = self.primaryKey() {
            return self.jsonPrimaryKey() ?? primaryKey
        }
        return nil
    }
    
    internal var isSync: Bool {
        return self.realm != nil && !self.isInvalidated
    }
    
    internal func validate(map: Map) {
        if map.mappingType == .fromJSON {
            if let context = map.context as? RealmMapContext {
                map.context = RealmMapContext.from(context: context, object: self)
                if self.isSync, !context.options.contains(.sync) {
                    context.options = context.options.union(.sync)
                }
            } else {
                map.context = RealmMapContext.from(object: self)
            }
        }
    }
    
    public func toJSON(shouldIncludeNilValues: Bool = false) -> [String:Any] {
        var JSON = [String:Any]()
        try? self.update {
            JSON = Mapper<Self>(shouldIncludeNilValues: shouldIncludeNilValues).toJSON($0)
        }
        return JSON
    }
    
    public func toJSONString(shouldIncludeNilValues: Bool = false, prettyPrint: Bool = false) -> String? {
        var JSONString: String?
        try? self.update{
            JSONString = Mapper<Self>(shouldIncludeNilValues: shouldIncludeNilValues).toJSONString($0, prettyPrint: prettyPrint)
        }
        return JSONString
    }
}
