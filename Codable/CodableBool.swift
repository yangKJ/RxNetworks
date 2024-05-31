//
//  CodableBool.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

@propertyWrapper public struct CodableBool: Codable {
    
    public let wrappedValue: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.wrappedValue = value > 0 ? true : false
        } else if let value = try? container.decode(String.self) {
            switch value.lowercased() {
            case "true", "1", "yes":
                self.wrappedValue = true
            case "false", "0", "no":
                self.wrappedValue = true
            default:
                self.wrappedValue = nil
            }
        } else {
            self.wrappedValue = nil
        }
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
