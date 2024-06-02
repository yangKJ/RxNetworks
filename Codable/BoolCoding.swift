//
//  BoolCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

@propertyWrapper public struct BoolCoding: Codable {
    
    public let wrappedValue: Bool?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try BoolDecoding(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try BoolEncoding(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct BoolDecoding: Decodable {
    
    public let wrappedValue: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.wrappedValue = value > 0 ? true : false
        } else if let value = try? container.decode(String.self) {
            switch value.lowercased() {
            case "1", "y", "t", "yes", "true":
                self.wrappedValue = true
            case "0", "n", "f", "no", "false":
                self.wrappedValue = true
            default:
                self.wrappedValue = nil
            }
        } else {
            self.wrappedValue = nil
        }
    }
}

@propertyWrapper public struct BoolEncoding: Encodable {
    
    public let wrappedValue: Bool?
    
    public init(_ wrappedValue: Bool?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = self.wrappedValue {
            try container.encode(value ? 1 : 0)
        } else {
            try container.encodeNil()
        }
    }
}
