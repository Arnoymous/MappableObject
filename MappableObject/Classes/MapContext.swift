//
//  MapContext.swift
//  Pods
//
//  Created by Arnaud Dorgans on 03/09/2017.
//
//

import UIKit
import RealmSwift
import ObjectMapper

open class RealmMapContext: MapContext {

    var realm: Realm?
    var options: RealmMapOptions = []
    
    public init() { }
    
    internal convenience init(options: RealmMapOptions) {
        self.init(options: options, realm: nil)
    }
    
    internal convenience init(options: RealmMapOptions, realm: Realm?) {
        self.init()
        self.realm = realm
        self.options = options
    }
    
    internal static func from(object: MappableObject? = nil, context: RealmMapContext? = nil, realm: Realm? = nil, options: RealmMapOptions? = nil) -> RealmMapContext {
        let context = context ?? RealmMapContext()
        if let options = options {
            context.options = options
        }
        if let realm = realm {
            context.realm = realm
        } else if let realm = object?.realm, context.realm == nil {
            context.realm = realm
        }
        return context
    }
}

public struct RealmMapOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let sync = RealmMapOptions(rawValue: 1 << 0) // sync with realm db
    public static let override = RealmMapOptions(rawValue: 1 << 1) // set default object's values for unprovided keys
    public static let copy = RealmMapOptions(rawValue: 1 << 2) // use detached objetcs
}
