//
//  Person.swift
//  MappableObject
//
//  Created by Arnaud Dorgans on 02/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MappableObject
import ObjectMapper
import RealmSwift

class Person: MappableObject {
    dynamic var name: String!
    dynamic var favoriteDog: Dog?
    
    let dogs = List<Dog>()
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    override func mappingPrimaryKey(map: Map) {
        name <- map["name"]
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        dogs <- map["dog_list"]
        favoriteDog <- map["fav_dog"]
    }
}
