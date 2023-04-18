//
//  Data+Ext.swift
//  Lemons
//
//  Created by Condy on 2023/4/4.
//

import Foundation

extension Data: LemonsWrapper { }

extension Lemon where Base == Data {
    
    /// Returns a string initialized by converting given data into unicode characters using a given encoding.
    /// - Parameter encoding: Unicode characters using a given encoding.
    /// - Returns: Data => string.
    public func toString(encoding: String.Encoding = .utf8) -> String? {
        String(data: base, encoding: encoding)
    }
}
