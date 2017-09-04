//
//  Helpers.swift
//  Pods
//
//  Created by Arnaud Dorgans on 02/09/2017.
//
//

import UIKit
import RealmSwift

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension ThreadConfined where Self: Object {
    public func update(block: (Self)->Void) throws {
        if let realm = self.realm {
            try realm.safeWrite{
                block(self)
            }
        } else {
            block(self)
        }
    }
}
