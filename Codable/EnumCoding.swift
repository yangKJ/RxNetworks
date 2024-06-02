//
//  EnumCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

/// 枚举系列
@propertyWrapper public struct EnumCoding<T: RawRepresentable>: Codable where T.RawValue: Codable {
    
    public let wrappedValue: T?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try EnumDecoding<T>(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try EnumEncoding<T>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct EnumDecoding<T: RawRepresentable>: Decodable where T.RawValue: Decodable {
    
    public let wrappedValue: T?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(T.RawValue.self) {
            self.wrappedValue = T.init(rawValue: value)
        } else {
            self.wrappedValue = nil
        }
    }
}

@propertyWrapper public struct EnumEncoding<T: RawRepresentable>: Encodable where T.RawValue: Encodable {
    
    public let wrappedValue: T?
    
    public init(_ wrappedValue: T? = nil) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let enumType = wrappedValue {
            try container.encode(enumType.rawValue)
        } else {
            try container.encodeNil()
        }
    }
}
