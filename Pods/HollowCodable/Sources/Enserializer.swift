//
//  Enserializer
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Encodable where Self: HollowCodable {
    
    public func toData(prettyPrint: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        encoder.setupKeyStrategy(Self.self)
        return try encoder.encode(self)
    }
    
    public func toJSON() -> [String: Any]? {
        do {
            let data = try toData()
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    public func toDictionary() throws -> [String: Any] {
        let data = try toData()
        let value = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dict = value as? [String: Any] else {
            throw HollowError.toDictionary
        }
        return dict
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        try? toJSONString(prettyPrinted: prettyPrint)
    }
    
    /// Serializes into a JSON string.
    /// - Parameter prettyPrinted: Whether to format print (adds line breaks in the JSON)
    /// - Returns: JSON string.
    public func toJSONString(prettyPrinted: Bool = false) throws -> String {
        let jsonData = try toData(prettyPrint: prettyPrinted)
        return String(decoding: jsonData, as: UTF8.self)
    }
}

extension Collection where Element: HollowCodable {
    
    public func toJSON() -> [[String: Any]] {
        self.compactMap { $0.toJSON() }
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        try? toJSONString(prettyPrinted: prettyPrint)
    }
    
    /// Serializes into a JSON string.
    /// - Parameter prettyPrinted: Whether to format print (adds line breaks in the JSON)
    /// - Returns: JSON string.
    public func toJSONString(prettyPrinted: Bool = false) throws -> String {
        let array = self.toJSON()
        let jsonData: Data
        if prettyPrinted {
            jsonData = try JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        } else {
            jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
        }
        guard let string = String(data: jsonData, encoding: String.Encoding.utf8) else {
            throw HollowError.toJSONString
        }
        return string
    }
}

extension Dictionary where Key: Encodable, Value: HollowCodable {
    
    public func toJSON() -> [Key: Value] {
        var dict = [Key: Value]()
        for (key, value) in self {
            dict[key] = value.toJSON() as? Value
        }
        return dict
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        try? toJSONString(prettyPrinted: prettyPrint)
    }
    
    public func toJSONString(prettyPrinted: Bool = false) throws -> String {
        let dict = self.toJSON()
        let jsonData: Data
        if prettyPrinted {
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        } else {
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        }
        guard let string = String(data: jsonData, encoding: String.Encoding.utf8) else {
            throw HollowError.toJSONString
        }
        return string
    }
}
