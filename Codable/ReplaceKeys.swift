//
//  ReplaceKeys.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

public struct ReplaceKeys {
    
    /// You need to replace it with a new coding key.
    public let replaceKey: String
    
    /// The old coding key will be replaced.
    public let originalKey: String
    
    public init(replaceKey: String, originalKey: String) {
        self.replaceKey = replaceKey
        self.originalKey = originalKey
    }
}

extension Collection where Element == ReplaceKeys {
    
    public var toDecoderingMappingKeys: Dictionary<String, String> {
        Dictionary(uniqueKeysWithValues: self.map {
            ($0.originalKey, $0.replaceKey)
        })
    }
    
    public var toEncoderingMappingKeys: Dictionary<String, String> {
        Dictionary(uniqueKeysWithValues: self.map {
            ($0.replaceKey, $0.originalKey)
        })
    }
}
