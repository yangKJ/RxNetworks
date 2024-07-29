//
//  LossyDictionaryCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/7.
//

import Foundation

/// Decodes Dictionaries filtering invalid key-value pairs if applicable
/// `@LossyDictionaryCoding` decodes Dictionaries and filters invalid key-value pairs if the Decoder is unable to decode the value.
/// This is useful if the Dictionary is intended to contain non-optional values.
public struct LossyDictionaryValue<Key: Hashable & Codable, Value: Codable>: Transformer {
    
    let value: [Key: Value]
    
    public typealias DecodeType = [Key: Value]
    public typealias EncodeType = [Key: Value]
    
    public static var selfDecodingFromDecoder: Bool {
        true
    }
    
    private struct LossyDecodableValue<T: Decodable>: Decodable {
        let value: T
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(T.self)
        }
    }
    
    public init?(value: Any) {
        guard let decoder = value as? Decoder else {
            return nil
        }
        do {
            var elements: [Key: Value] = [:]
            if Key.self == String.self {
                let container = try decoder.container(keyedBy: PathCodingKey.self)
                let keys = try Self.extractKeys(from: decoder, container: container)
                for (key, stringKey) in keys {
                    if let value = try? container.decode(LossyDecodableValue<Value>.self, forKey: key).value {
                        elements[stringKey as! Key] = value
                    }
                }
            } else if Key.self == Int.self {
                let container = try decoder.container(keyedBy: PathCodingKey.self)
                for key in container.allKeys where key.intValue != nil {
                    if let value = try? container.decode(LossyDecodableValue<Value>.self, forKey: key).value {
                        elements[key.intValue! as! Key] = value
                    }
                }
            } else {
                return nil
            }
            if elements.isEmpty {
                return nil
            }
            self.value = elements
        } catch {
            return nil
        }
    }
    
    public func transform() throws -> [Key: Value]? {
        value
    }
    
    private static func extractKeys(
        from decoder: Decoder,
        container: KeyedDecodingContainer<PathCodingKey>
    ) throws -> [(PathCodingKey, String)] {
        // Decode a dictionary ignoring the values to decode the original keys
        // without using the `JSONDecoder.KeyDecodingStrategy`.
        let keys = try decoder.singleValueContainer().decode([String: CodableAnyValue].self).keys
        return zip(
            container.allKeys.sorted(by: { $0.stringValue < $1.stringValue }),
            keys.sorted()
        ).map { ($0, $1) }
    }
}

extension LossyDictionaryValue: DefaultValueProvider {
    
    public typealias DefaultType = [Key: Value]
    
    public static var hasDefaultValue: DefaultType {
        [:]
    }
}
