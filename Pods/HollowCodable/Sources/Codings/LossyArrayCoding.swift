//
//  LossyArrayCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/7/7.
//

import Foundation

/// Decodes Arrays filtering invalid values if applicable.
/// `@LossyArrayCoding` decodes Arrays and filters invalid values if the Decoder is unable to decode the value.
/// This is useful if the Array is intended to contain non-optional types.
public struct LossyArrayValue<T: Codable>: Transformer {
    
    let value: [T]
    
    public typealias DecodeType = [T]
    public typealias EncodeType = [T]
    
    public static var selfDecodingFromDecoder: Bool {
        true
    }
    
    public init?(value: Any) {
        guard let decoder = value as? Decoder, var container = try? decoder.unkeyedContainer() else {
            return nil
        }
        var items: [T] = []
        items.reserveCapacity(container.count ?? 0)
        while !container.isAtEnd {
            do {
                //let value = try container.decode(T.self)
                // At least for PLists, `decodeIfPresent` seems to break when a value is `$null`.
                // This is why `Optional<T>` is required.
                if let item = try container.decodeIfPresent(Optional<T>.self) as? T {
                    items.append(item)
                }
            } catch {
                _ = try? container.superDecoder()
            }
        }
        if items.isEmpty {
            return nil
        }
        self.value = items
    }
    
    public func transform() throws -> [T]? {
        value
    }
}

extension LossyArrayValue: Equatable where T: Equatable { }
extension LossyArrayValue: Hashable where T: Hashable { }

extension LossyArrayValue: DefaultValueProvider {
    
    public typealias DefaultType = [T]
    
    public static var hasDefaultValue: DefaultType {
        []
    }
}
