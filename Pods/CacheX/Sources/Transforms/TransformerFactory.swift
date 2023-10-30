//
//  TransformerFactory.swift
//  CacheX
//
//  Created by Condy on 2023/3/23.
//  

import Foundation

struct TransformerFactory<T> {
    
    let toData: (T) throws -> Data
    let fromData: (Data) throws -> T
    
    init(toData: @escaping (T) throws -> Data, fromData: @escaping (Data) throws -> T) {
        self.toData = toData
        self.fromData = fromData
    }
    
    static func forCodable() -> TransformerFactory<T> where T: Codable {
        let toData: (T) throws -> Data = { object in
            let encoder = JSONEncoder()
            return try encoder.encode(object)
        }
        
        let fromData: (Data) throws -> T = { data in
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }
        return TransformerFactory<T>(toData: toData, fromData: fromData)
    }
    
//    static func forTransformeable<T: Transformeable>(_ type: T.Type) -> Transformer<T> {
//        let toData: (T) throws -> Data = { object in
//
//        }
//
//        let fromData: (Data) throws -> T = { data in
//            let decoder = JSONDecoder()
//            decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: data)
//        }
//        return Transformer<T>(toData: toData, fromData: fromData)
//    }
}
