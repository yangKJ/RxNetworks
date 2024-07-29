//
//  Merger.swift
//  CodableExample
//
//  Created by Condy on 2024/7/7.
//

import Foundation

public struct Merger<T: HollowCodable> {
    
    public static func merge<A: HollowCodable>(objects: A...) throws -> T {
        var dictionary = [String: Any]()
        for obj in objects {
            dictionary = dictionary.merging(try obj.toDictionary()) { $1 }
        }
        return try T.deserialize(element: dictionary)
    }
    
    public static func merge<A: HollowCodable, B: HollowCodable>(_ aObject: A, _ bObject: B) throws -> T {
        let dictionary = try aObject.toDictionary()
            .merging(try bObject.toDictionary()) { $1 }
        return try T.deserialize(element: dictionary)
    }
    
    public static func merge<A: HollowCodable, B: HollowCodable, C: HollowCodable>(_ aObject: A, _ bObject: B, _ cObject: C) throws -> T {
        let dictionary = try aObject.toDictionary()
            .merging(try bObject.toDictionary()) { $1 }
            .merging(try cObject.toDictionary()) { $1 }
        return try T.deserialize(element: dictionary)
    }
    
    public static func merge<A: HollowCodable, B: HollowCodable, C: HollowCodable, D: HollowCodable>(_ aObject: A, _ bObject: B, _ cObject: C, _ dObject: D) throws -> T {
        let dictionary = try aObject.toDictionary()
            .merging(try bObject.toDictionary()) { $1 }
            .merging(try cObject.toDictionary()) { $1 }
            .merging(try dObject.toDictionary()) { $1 }
        return try T.deserialize(element: dictionary)
    }
}
