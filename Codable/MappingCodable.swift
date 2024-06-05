//
//  MappingCodable.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public protocol MappingCodable: Codable {
    /// Setup the coding key that needs to be replaced.
    static var codingKeys: [ReplaceKeys] { get }
}

extension MappingCodable {
    
    public static var codingKeys: [ReplaceKeys] {
        []
    }
    
    public func toData(prettyPrint: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        let mapKeys = Self.codingKeys
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
        guard let jsonData = try? encoder.encode(self) else {
            return nil
        }
        return jsonData
    }
    
    public func toDictionary() -> [String : Any] {
        guard let data = toData(),
              let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
            return [:]
        }
        return dict
    }
    
    public func toJSONString() -> String? {
        guard let jsonData = toData() else {
            return nil
        }
        return String(decoding: jsonData, as: UTF8.self)
    }
}

extension Collection where Element: MappingCodable {
    
    public func toJSONString() -> String? {
        let array = toJSONArray()
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: []) else {
            return nil
        }
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    public func toJSONArray() -> [String] {
        self.compactMap {
            $0.toJSONString()
        }
    }
}
