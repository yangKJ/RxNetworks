//
//  CodableBase64Data.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

@propertyWrapper public struct CodableBase64Data: Codable {
    
    public let wrappedValue: Data?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.wrappedValue = Data.init(base64Encoded: value)
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
