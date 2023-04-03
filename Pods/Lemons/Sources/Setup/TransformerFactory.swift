//
//  TransformerFactory.swift
//  Lemons
//
//  Created by Condy on 2023/3/23.
//  

import Foundation

struct TransformerFactory {
    /// Used to wrap Codable object
    struct WrapCodable<T: Codable>: Codable {
        let object: T
    }
    
    static func forCodable<U: Codable>(ofType: U.Type) -> Transformer<U> {
        let toData: (U) throws -> Data = { object in
            let encoder = JSONEncoder()
            return try encoder.encode(WrapCodable<U>(object: object))
        }
        
        let fromData: (Data) throws -> U = { data in
            let decoder = JSONDecoder()
            return try decoder.decode(WrapCodable<U>.self, from: data).object
        }
        return Transformer<U>(toData: toData, fromData: fromData)
    }
}
