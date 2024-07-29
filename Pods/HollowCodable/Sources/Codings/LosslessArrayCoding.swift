//
//  LosslessArrayCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/20.
//

import Foundation

public typealias LosslessArrayValue<T: LosslessStringConvertible & Codable> = LosslessArrayHasValue<T, DefaultLosslessDecodingTypes>

/// Decodes Arrays by attempting to decode its elements into their preferred types.
/// `@LosslessArrayCoding` attempts to decode Arrays and their elements into their preferred types while preserving the data.
/// This is useful when data may return unpredictable values when a consumer is expecting a certain type.
/// For instance, if an API sends an array of SKUs as either `Int`s or `String`s.
/// Then a `@LosslessArrayCoding` can ensure the elements are always decoded as `String`s.
public struct LosslessArrayHasValue<T: LosslessStringConvertible, Has: HasLosslessable>: Transformer where T: Codable {
    
    let value: [T]
    
    public typealias DecodeType = [T]
    public typealias EncodeType = [T]
    
    public static var selfDecodingFromDecoder: Bool {
        true
    }
    
    public static var selfEncodingFromEncoder: Bool {
        true
    }
    
    public init?(value: Any) {
        guard let decoder = value as? Decoder, var container = try? decoder.unkeyedContainer() else {
            return nil
        }
        var elements: [T] = []
        while !container.isAtEnd {
            do {
                let decoding = try container.decode(AnyBacked<LosslessHasValue<T, Has>>.self)
                if let value = decoding.wrappedValue {
                    elements.append(value)
                }
            } catch {
                _ = try? container.superDecoder()
            }
        }
        if elements.isEmpty {
            return nil
        }
        self.value = elements
    }
    
    public func transform() throws -> [T]? {
        value
    }
    
    public static func transform(from value: [T], to encoder: any Encoder) throws {
        try value.map({ $0.description }).encode(to: encoder)
    }
}

extension LosslessArrayHasValue: Equatable where T: Equatable { }
extension LosslessArrayHasValue: Hashable where T: Hashable { }

extension LosslessArrayHasValue: DefaultValueProvider {
    
    public typealias DefaultType = [T]
    
    public static var hasDefaultValue: DefaultType {
        []
    }
}
