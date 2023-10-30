//
//  Extensions.swift
//  CacheX
//
//  Created by Condy on 2023/3/30.
//

import Foundation

extension CacheXWrapper where Base == Data {
    
    /// Returns a string initialized by converting given data into unicode characters using a given encoding.
    /// - Parameter encoding: Unicode characters using a given encoding.
    /// - Returns: Data => string.
    public func toString(encoding: String.Encoding = .utf8) -> String? {
        String(data: base, encoding: encoding)
    }
}

extension CacheXWrapper where Base == String {
    
    /// Encrypt strings.
    /// - Parameter type: Type of encryption.
    /// - Returns: Encrypted string.
    public func encrypted(type: CryptoType) -> String {
        type.encryptedString(with: base)
    }
    
    /// Returns a data containing a representation of the string encoded using a given encoding.
    /// - Parameter using: Encoded using a given encoding.
    /// - Returns: String => data.
    public func toData(using: String.Encoding = .utf8) -> Data? {
        base.data(using: using)
    }
}
