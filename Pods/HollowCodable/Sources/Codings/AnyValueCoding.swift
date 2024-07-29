//
//  AnyValueCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/6/23.
//

import Foundation

/// Support any value property wrapper with dictionary.
/// `@DictionaryCoding` decodes any value json into `[String: Any]`.
public struct AnyDictionary: Transformer, DefaultValueProvider {
    
    let dict: [String: CodableAnyValue]
    
    public typealias DecodeType = [String: Any]
    public typealias EncodeType = [String: CodableAnyValue]
    
    public static var useCodableAnyValueDecoding: Bool {
        true
    }
    
    public static var hasDefaultValue: [String: Any] {
        [:]
    }
    
    public init?(value: Any) {
        guard let value = value as? CodableAnyValue else {
            return nil
        }
        switch value {
        case .dictionary(let res):
            self.dict = res
        default:
            return nil
        }
    }
    
    public func transform() throws -> [String: Any]? {
        dict.mapValues(\.value) as? [String: Any]
    }
    
    public static func transform(from value: [String: Any]) throws -> [String: CodableAnyValue] {
        value.compactMapValues(CodableAnyValue.init(value:))
    }
}

/// Support any value dictionary property wrapper with array.
/// `@ArrayDictionaryCoding` decodes any value json into `[[String: Any]]`.
public struct AnyDictionaryArray: Transformer, DefaultValueProvider {
    
    let dictArray: [[String: CodableAnyValue]]
    
    public typealias DecodeType = [[String: Any]]
    public typealias EncodeType = [[String: CodableAnyValue]]
    
    public static var useCodableAnyValueDecoding: Bool {
        true
    }
    
    public static var hasDefaultValue: [[String: Any]] {
        []
    }
    
    public init?(value: Any) {
        guard let value = value as? CodableAnyValue else {
            return nil
        }
        switch value {
        case .array(let res):
            let array = res.compactMap({
                if case .dictionary(let dict) = $0 {
                    return dict
                }
                return nil
            })
            self.dictArray = array
        default:
            return nil
        }
    }
    
    public func transform() throws -> [[String: Any]]? {
        dictArray.compactMap {
            $0.mapValues(\.value) as? [String: Any]
        }
    }
    
    public static func transform(from value: [[String: Any]]) throws -> [[String: CodableAnyValue]] {
        value.map {
            $0.compactMapValues(CodableAnyValue.init(value:))
        }
    }
}

/// Support any value property wrapper with array.
/// `@ArrayCoding` decodes any value json into `[Any]`.
public struct AnyArray: Transformer, DefaultValueProvider {
    
    let array: [CodableAnyValue]
    
    public typealias DecodeType = [Any]
    public typealias EncodeType = [CodableAnyValue]
    
    public static var useCodableAnyValueDecoding: Bool {
        true
    }
    
    public static var hasDefaultValue: [Any] {
        []
    }
    
    public init?(value: Any) {
        guard let value = value as? CodableAnyValue else {
            return nil
        }
        switch value {
        case .array(let res):
            self.array = res
        default:
            return nil
        }
    }
    
    public func transform() throws -> [Any]? {
        array.compactMap {
            $0.value
        }
    }
    
    public static func transform(from value: [Any]) throws -> [CodableAnyValue] {
        value.compactMap {
            CodableAnyValue.init(value: $0)
        }
    }
}

/// Support any value property wrapper with Any.
/// `@AnyXCoding` decodes any value json into `Any`.
public struct AnyX: Transformer {
    
    let value: CodableAnyValue
    
    public typealias DecodeType = Any
    public typealias EncodeType = CodableAnyValue
    
    public static var useCodableAnyValueDecoding: Bool {
        true
    }
    
    public init?(value: Any) {
        guard let value = value as? CodableAnyValue else {
            return nil
        }
        self.value = value
    }
    
    public func transform() throws -> Any? {
        value.value
    }
    
    public static func transform(from value: Any) throws -> CodableAnyValue {
        CodableAnyValue.init(value: value) ?? .null
    }
}
