//
//  String+Ext.swift
//  Lemons
//
//  Created by Condy on 2023/4/4.
//

import Foundation

extension String: LemonsWrapper { }

extension Lemon where Base == String {
    
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
