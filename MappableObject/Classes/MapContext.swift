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
}

public struct RealmMapOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let sync = RealmMapOptions(rawValue: 1 << 0)
}
