//
//  IgnoredKey.swift
//  CodableExample
//
//  Created by Condy on 2024/6/18.
//

import Foundation

/// Add this to an Optional Property to not included it when Encoding or Decoding
@propertyWrapper public struct IgnoredKey<T: Codable>: OmitableFromEncoding & OmitableFromDecoding {
    public var wrappedValue: T?
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper public struct IgnoredKeyEncoding<T: Encodable>: OmitableFromEncoding {
    public var wrappedValue: T?
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper public struct IgnoredKeyDecoding<T: Decodable>: OmitableFromDecoding {
    public var wrappedValue: T?
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    // This is used to override the default decoding behavior for OptionalCodingWrapper to allow a value to avoid a missing key Error
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: OmitableFromDecoding {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {
    // Used to make make sure OmitableFromEncoding never encodes a value
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: OmitableFromEncoding {
        return
    }
}

public protocol OmitableFromEncoding: Encodable { }

extension OmitableFromEncoding {
    // This shouldn't ever be called since KeyedEncodingContainer should skip it due to the included extension
    public func encode(to encoder: Encoder) throws { return }
}

public protocol OmitableFromDecoding: Decodable {
    associatedtype T: ExpressibleByNilLiteral
    init(wrappedValue: T)
}

extension OmitableFromDecoding {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: nil)
    }
}

extension IgnoredKeyEncoding: Decodable where T: Decodable { }
extension IgnoredKeyDecoding: Encodable where T: Encodable { }

extension IgnoredKeyEncoding: Equatable where T: Equatable { }
extension IgnoredKeyDecoding: Equatable where T: Equatable { }
extension IgnoredKey: Equatable where T: Equatable { }

extension IgnoredKeyEncoding: Hashable where T: Hashable { }
extension IgnoredKeyDecoding: Hashable where T: Hashable { }
extension IgnoredKey: Hashable where T: Hashable { }
