//
//  Base64DataCoding.swift
//  CodableExample
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Hollow {
    public enum Base64Data: DataConverter { }
}

/// Uses Base64 for (de)serailization of `Data`.
/// `@Base64Coding` decodes base64 data strings into `Data`.
/// Decodes strictly valid Base64. This does not handle b64url encoding, invalid padding, or unknown characters.
extension Hollow.Base64Data {
    
    public typealias Value = String
    public typealias FromValue = Data
    public typealias ToValue = String
    
    public static let hasValue: String = ""
    
    public static func transformToValue(with value: Data) -> String? {
        value.base64EncodedString()
    }
    
    public static func transformFromValue(with value: String) -> Data? {
        Data(base64Encoded: value)
    }
}
