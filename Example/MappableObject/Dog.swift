//
//  Dog.swift
//  MappableObject
//
//  Created by Arnaud Dorgans on 02/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import MappableObject

class Dog: MappableObject {
    dynamic var name: String!
    dynamic var age = 0
    
    let owners = LinkingObjects(fromType: Person.self, property: "dogs")
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    override func mappingPrimaryKey(map: Map) {
        name <- map["name"]
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        age <- map["age"]
    }
}
