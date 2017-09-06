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
```

Map sync, copy with DB
```swift
let person = Mapper<Person>(options: [.sync, .copy]).map(JSON: ["full_name": "Arnaud Dorgans"]) //detached from realm
```

#### Update
Override
```swift
var person = Mapper<Person>(options: .sync).map(JSON: ["full_name": "Arnaud Dorgans", "dogs": [["name": "Sansa", "age": 1]]])!
person.update{
   person = Mapper<Person>(options: [.sync, .override]).map(JSON: ["full_name": "Arnaud Dorgans"], toObject: $0) //dogs will be reset to default value [] cause 'dogs' key is not provided
}
```

## Author

Arnoymous, arnaud.dorgans@gmail.com

## License

MappableObject is available under the MIT license. See the LICENSE file for more info.
