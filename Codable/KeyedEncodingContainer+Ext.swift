//
//  KeyedEncodingContainer+Ext.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension KeyedEncodingContainer {
    
    public mutating func encodeIfPresent<T>(_ value: T?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard let value = value else {
            try self.encodeNil(forKey: key)
            return
        }
        try self.encode(value, forKey: key)
    }
    
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        switch value {
        case let col as HollowColor:
            try self.encode(HexColorEncoding.hexString(color: col), forKey: key)
        case let del as NSDecimalNumber:
            try self.encode(del.description, forKey: key)
        case let ee as Encodable:
            try self.encode(ee, forKey: key)
        default:
            break
        }
    }
    
    public mutating func encodeIfPresent<R: RawRepresentable>(_ value: R?, forKey key: KeyedEncodingContainer<K>.Key) throws where R.RawValue: Encodable {
        guard let value = value else {
            try self.encodeNil(forKey: key)
            return
        }
        try self.encode(value, forKey: key)
    }
    
    public mutating func encode<R: RawRepresentable>(_ value: R, forKey key: KeyedEncodingContainer<K>.Key) throws where R.RawValue: Encodable {
        try self.encode(value.rawValue, forKey: key)
    }
}
