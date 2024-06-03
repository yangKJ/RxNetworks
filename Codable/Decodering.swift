//
//  Decodering.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct Decodering<T: Decodable> {
    
    public static func decodering(_ type: MappingCodable.Type, element: Any) throws -> T {
        let decoder = JSONDecoder()
        let mapKeys = type.codingKeys
        if !mapKeys.isEmpty {
            let mapping = mapKeys.toDecoderingMappingKeys
            decoder.keyDecodingStrategy = .custom({ codingPath in
                let key = codingPath.last!.stringValue
                if let mapped = mapping[key] {
                    return AnyCodingKey(stringValue: mapped)
                } else {
                    return AnyCodingKey(stringValue: key)
                }
            })
        }
        if let data = element as? Data {
            return try decoder.decode(T.self, from: data)
        }
        let data = try JSONSerialization.data(withJSONObject: element)
        return try decoder.decode(T.self, from: data)
    }
}
