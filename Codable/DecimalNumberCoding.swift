//
//  DecimalNumberCoding.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

@propertyWrapper public struct DecimalNumberCoding: Codable {
    
    public let wrappedValue: NSDecimalNumber?
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try DecimalNumberDecoding(from: decoder).wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try DecimalNumberEncoding(wrappedValue).encode(to: encoder)
    }
}

@propertyWrapper public struct DecimalNumberDecoding: Decodable {
    
    public let wrappedValue: NSDecimalNumber?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decimal(string: String?) -> NSDecimalNumber? {
            guard let string = string, string.count > 0 else {
                return nil
            }
            let decimal = NSDecimalNumber(string: string)
            if decimal != .notANumber {
                return decimal
            }
            return nil
        }
        if let val = try? container.decode(String.self) {
            self.wrappedValue = decimal(string: val)
        } else if let val = try? container.decode(Float.self) {
            self.wrappedValue = decimal(string: String(describing: val))
        } else if let val = try? container.decode(Int.self) {
            self.wrappedValue = decimal(string: String(describing: val))
        } else if let val = try? container.decode(CGFloat.self) {
            self.wrappedValue = decimal(string: String(describing: val))
        } else if let val = try? container.decode(Int64.self) {
            self.wrappedValue = decimal(string: String(describing: val))
        } else if let val = try? container.decode(Double.self) {
            self.wrappedValue = decimal(string: String(describing: val))
        } else {
            self.wrappedValue = decimal(string: nil)
        }
    }
}

@propertyWrapper public struct DecimalNumberEncoding: Encodable {
    
    public let wrappedValue: NSDecimalNumber?
    
    public init(_ wrappedValue: NSDecimalNumber?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let decimal = wrappedValue {
            try container.encode(decimal.description)
        } else {
            try container.encodeNil()
        }
    }
}
