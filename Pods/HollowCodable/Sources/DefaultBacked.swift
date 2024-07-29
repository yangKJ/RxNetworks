//
//  DefaultBacked.swift
//  CodableExample
//
//  Created by Condy on 2024/6/16.
//

import Foundation

public typealias DefaultBackedCoding<T: Transformer> = DefaultBacked<T> where T: DefaultValueProvider, T.DefaultType == T.DecodeType

/// Decodes values with a reasonable default value.
/// Provides a default value for missing `Decodable` data.
/// `@DefaultBacked` attempts to decode a value and falls back to a default type provided by the generic `DefaultValueProvider`.
@propertyWrapper public struct DefaultBacked<T: Transformer & DefaultValueProvider>: Codable where T.DefaultType == T.DecodeType {
    
    public var wrappedValue: T.DecodeType
    
    @inlinable public init(_ wrappedValue: T.DecodeType? = nil) {
        self.wrappedValue = wrappedValue ?? T.hasDefaultValue
    }
    
    @inlinable public init(from decoder: Decoder) throws {
        self.wrappedValue = try DefaultBackedDecoding<T>.init(from: decoder).wrappedValue
    }
    
    @inlinable public func encode(to encoder: Encoder) throws {
        try DefaultBackedEncoding<T>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct DefaultBackedDecoding<T: DecodeTransformer & DefaultValueProvider>: Decodable where T.DefaultType == T.DecodeType {
    
    public var wrappedValue: T.DecodeType
    
    @inlinable public init(from decoder: Decoder) throws {
        self.wrappedValue = try AnyBackedDecoding<T>.init(from: decoder).wrappedValue ?? T.hasDefaultValue
    }
}

@propertyWrapper public struct DefaultBackedEncoding<T: EncodeTransformer & DefaultValueProvider>: Encodable where T.DefaultType == T.DecodeType {
    
    public let wrappedValue: T.DecodeType?
    
    @inlinable public init(_ wrappedValue: T.DecodeType? = nil) {
        self.wrappedValue = wrappedValue
    }
    
    @inlinable public func encode(to encoder: Encoder) throws {
        let value = wrappedValue ?? T.hasDefaultValue
        try AnyBackedEncoding<T>(value).encode(to: encoder)
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: DefaultBacked<T>.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> DefaultBacked<T> {
        if let result = try? decodeIfPresent(DefaultBacked<T>.self, forKey: key) {
            return result
        }
        return DefaultBacked.init(T.hasDefaultValue)
    }
}
