//
//  KeyedDecodingContainer+Ext.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension KeyedDecodingContainer {
    
    public func decodeIfPresent(_ type: HollowColor.Type, forKey key: Key) throws -> HollowColor? {
        let value = try self.decode(String.self, forKey: key)
        return HexColorDecoding.color(with: value)
    }
    
    public func decodeIfPresent(_ type: NSDecimalNumber.Type, forKey key: Key) throws -> NSDecimalNumber? {
        if let val = try? self.decode(String.self, forKey: key) {
            return decimal(string: val)
        }
        if let val = try? self.decode(Float.self, forKey: key) {
            return decimal(string: String(describing: val))
        }
        if let val = try? self.decode(Int.self, forKey: key) {
            return decimal(string: String(describing: val))
        }
        if let val = try? self.decode(CGFloat.self, forKey: key) {
            return decimal(string: String(describing: val))
        }
        if let val = try? self.decode(Int64.self, forKey: key) {
            return decimal(string: String(describing: val))
        }
        if let val = try? self.decode(Double.self, forKey: key) {
            return decimal(string: String(describing: val))
        }
        return nil
    }
    
    public func decodeIfPresent<T: RawRepresentable>(_ type: T.Type, forKey key: Key) throws -> T? where T.RawValue: Decodable {
        let value = try self.decode(T.RawValue.self, forKey: key)
        return T.init(rawValue: value)
    }
}

extension KeyedDecodingContainer {
    
    private func decimal(string: String) -> NSDecimalNumber? {
        if string.count > 0 {
            let decimal = NSDecimalNumber(string: string)
            if decimal != .notANumber {
                return decimal
            }
        }
        return nil
    }
}
