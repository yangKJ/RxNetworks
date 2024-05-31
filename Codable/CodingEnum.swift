//
//  CodingEnum.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

/// 枚举系列
@propertyWrapper public struct CodingEnum<T: RawRepresentable>: Codable where T.RawValue: Codable {
    
    public let wrappedValue: T?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(T.RawValue.self) {
            self.wrappedValue = T.init(rawValue: value)
        } else {
            self.wrappedValue = nil
        }
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
