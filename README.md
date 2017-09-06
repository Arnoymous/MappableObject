# MappableObject

[![CI Status](http://img.shields.io/travis/Arnoymous/MappableObject.svg?style=flat)](https://travis-ci.org/Arnoymous/MappableObject)
[![Version](https://img.shields.io/cocoapods/v/MappableObject.svg?style=flat)](http://cocoapods.org/pods/MappableObject)
[![License](https://img.shields.io/cocoapods/l/MappableObject.svg?style=flat)](http://cocoapods.org/pods/MappableObject)
[![Platform](https://img.shields.io/cocoapods/p/MappableObject.svg?style=flat)](http://cocoapods.org/pods/MappableObject)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MappableObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MappableObject"
```

## Usage

#### Object without primaryKey
```swift
class Cat: MappableObject {
    
    dynamic var name: String = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        name <- map["name"]
    }
}
```

#### Object with primaryKey
```swift
class Dog: MappableObject {
    
    dynamic var name: String = ""
    dynamic var age: Int = 0
    
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
```

#### Object with primaryKey different in JSON
```swift
class Person: MappableObject {
    
    dynamic var name: String = ""
    let dogs = List<Dog>()
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    override class func jsonPrimaryKey() -> String? {
        return "full_name"
    }
    
    override func mappingPrimaryKey(map: Map) {
        name <- map["full_name"]
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        dogs <- map["dogs"]
    }
}
```

#### Custom MapContext
```swift
class CustomContext: RealmMapContext {
    
    var customValue: String
    
    init(customValue: String) {
        self.customValue = customValue
        super.init()
    }
}
```

#### Mapper
Map
```swift
let person = Mapper<Person>().map(JSON: ["full_name": "Arnaud Dorgans"])
```

Map sync with DB
```swift
let person = Mapper<Person>(options: .sync).map(JSON: ["full_name": "Arnaud Dorgans"])
//get or create Person in DB with 'Arnaud Dorgans' primary key
```

Map sync, copy with DB
```swift
let person = Mapper<Person>(options: [.sync, .copy]).map(JSON: ["full_name": "Arnaud Dorgans"]) 
//get Person from DB with 'Arnaud Dorgans' primary key, or create Person from JSON detached from Realm
//and then update detached object from JSON
```

#### Update

```swift
let mapper = Mapper<Person>(options: .sync)
var person = mapper.map(JSON: ["full_name": "Arnaud Dorgans", "dogs": [["name": "Sansa", "age": 1]]])! 
// get or create Person in DB with 'Arnaud Dorgans' primary key & update 'dogs' property
let realm = try! Realm()
realm.write{
   person = mapper.map(JSON: ["full_name": "Arnaud Dorgans"], toObject: person) 
   //dogs won't be updated  cause 'dogs' key isn't provided
   person = mapper.map(JSON: ["full_name": "Arnaud Dorgans", "dogs": []], toObject: person) 
   //dogs will be updated cause 'dogs' key is provided
}
```

Override
```swift
var person = Mapper<Person>(options: .sync).map(JSON: ["full_name": "Arnaud Dorgans", "dogs": [["name": "Sansa", "age": 1]]])!
let realm = try! Realm()
realm.write{
   person = Mapper<Person>(options: [.sync, .override]).map(JSON: ["full_name": "Arnaud Dorgans"], toObject: person) 
   //dogs will be reset to default value [] cause 'dogs' key isn't provided
}
```

## Author

Arnoymous, arnaud.dorgans@gmail.com

## License

MappableObject is available under the MIT license. See the LICENSE file for more info.
