//
//  BoolHasCoding.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

@propertyWrapper public struct BoolHasCoding<Def: HollowValueProvider>: Codable {
    
    public let wrappedValue: Bool
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try BoolHasDecoding<Def>(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try BoolHasEncoding<Def>(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct BoolHasDecoding<Def: HollowValueProvider>: Decodable {
    
    public let wrappedValue: Bool
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try BoolDecoding(from: decoder).wrappedValue ?? Self.def
    }
    
    static var def: Bool {
        guard let value = Def.hasValue as? Bool else {
            return false
        }
        return value
    }
}

@propertyWrapper public struct BoolHasEncoding<Def: HollowValueProvider>: Encodable {
    
    public let wrappedValue: Bool?
    
    public init(_ wrappedValue: Bool?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = self.wrappedValue {
            try container.encode(value ? 1 : 0)
        } else {
            if let value = Self.def {
                try container.encode(value ? 1 : 0)
            } else {
                try container.encodeNil()
            }
        }
    }
    
    static var def: Bool? {
        guard let value = Def.hasValue as? Bool else {
            return nil
        }
        return value
    }
}
