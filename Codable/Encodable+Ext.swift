//
//  Encodable+Ext.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Encodable {
    
    public func toJSONString(_ type: MappingCodable.Type, prettyPrint: Bool = false) throws -> String {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        let mapKeys = type.codingKeys
        if !mapKeys.isEmpty {
            let mapping = mapKeys.toEncoderingMappingKeys
            encoder.keyEncodingStrategy = .custom({ codingPath in
                let key = codingPath.last!.stringValue
                if let mapped = mapping[key] {
                    return AnyCodingKey(stringValue: mapped)
                } else {
                    return AnyCodingKey(stringValue: key)
                }
            })
        }
        let jsonData = try encoder.encode(self)
        return String(decoding: jsonData, as: UTF8.self)
    }
    
    public func toJSONString(prettyPrint: Bool = false) throws -> String {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        let jsonData = try encoder.encode(self)
        return String(decoding: jsonData, as: UTF8.self)
    }
}
