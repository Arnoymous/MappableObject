//
//  Cat.swift
//  MappableObject
//
//  Created by Arnaud Dorgans on 02/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper
import MappableObject

class Cat: MappableObject {

    dynamic var name: String!
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        name <- map["catName"]
    }
}
