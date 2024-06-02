//
//  Base64DataCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

@propertyWrapper public struct Base64DataCoding: Codable {
    
    public let wrappedValue: Data?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try Base64DataDecoding(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try Base64DataEncoding(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct Base64DataDecoding: Decodable {
    
    public let wrappedValue: Data?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.wrappedValue = Data.init(base64Encoded: value)
    }
}

@propertyWrapper public struct Base64DataEncoding: Encodable {
    
    public let wrappedValue: Data?
    
    public init(_ wrappedValue: Data?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = self.wrappedValue {
            try container.encode(value.base64EncodedString())
        } else {
            try container.encodeNil()
        }
    }
}
