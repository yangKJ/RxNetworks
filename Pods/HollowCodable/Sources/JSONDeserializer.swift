//
//  JSONDeserializer.swift
//  CodableExample
//
//  Created by Condy on 2024/7/18.
//

import Foundation

public struct JSONDeserializer<T: Decodable> {
    
    /// Finds the internal dictionary in any as the `designatedPath` specified, and map it to a Model.
    /// `designatedPath` is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    public static func deserialize(from element: Any, designatedPath: String? = nil, options: DecodingOptions = [], using type: HollowCodable.Type) throws -> T {
        let decoder = JSONDecoder()
        let hasNestedKeys = decoder.setupKeyStrategy(type, options: options)
        decoder.hasNestedKeys = hasNestedKeys
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            if options.contains(.allowsJSON5) {
                decoder.allowsJSON5 = true
            }
            if options.contains(.assumesTopLevelDictionary) {
                decoder.assumesTopLevelDictionary = true
            }
        }
        let data: Data
        if let designatedPath = designatedPath, !designatedPath.isEmpty {
            if let obj = toObject(element) {
                let designatedPathObject = getDesignatedPathObject(obj, by: designatedPath)
                data = try toData(designatedPathObject ?? element)
            } else {
                data = try toData(element)
            }
        } else {
            data = try toData(element)
        }
        let result = try decoder.decode(T.self, from: data)
        return result
    }
}

extension JSONDeserializer {
    static func toData(_ value: Any) throws -> Data {
        switch value {
        case let data as Data:
            return data
        case let string as String:
            guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
                throw HollowError.stringToData
            }
            return data
        case let dict as Dictionary<String, Any>:
            guard JSONSerialization.isValidJSONObject(dict) else {
                throw HollowError.invalidJSONObject
            }
            return try JSONSerialization.data(withJSONObject: dict)
        case let array as Array<Any>:
            guard JSONSerialization.isValidJSONObject(array) else {
                throw HollowError.invalidJSONObject
            }
            return try JSONSerialization.data(withJSONObject: array)
        default:
            return try JSONSerialization.data(withJSONObject: value)
        }
    }
    
    static func toObject(_ value: Any) -> Any? {
        switch value {
        case let data as Data:
            return data.hc.toJSONObject()
        case let json as String:
            return json.hc.toJSONObject()
        case let dict as Dictionary<String, Any>:
            return dict
        case let array as Array<Any>:
            return array
        default:
            return nil
        }
    }
    
    /// The information to be parsed is obtained through the path, then converted into data and provided to the decoder for parsing.
    static func getDesignatedPathObject(_ object: Any, by designatedPath: String) -> Any? {
        let paths = designatedPath.components(separatedBy: ".")
        guard paths.count > 0 else {
            return object
        }
        var result = object
        var abort = false
        var next = object as? [String: Any]
        paths.forEach({ (seg) in
            if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
                return
            }
            if let _next = next?[seg] {
                result = _next
                next = _next as? [String: Any]
            } else {
                abort = true
            }
        })
        return abort ? nil : result
    }
}
