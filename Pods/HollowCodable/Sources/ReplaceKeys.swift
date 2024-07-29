//
//  ReplaceKeys.swift
//  HollowCodable
//
//  Created by Condy on 2024/6/1.
//

import Foundation

public typealias AlterCodingKeys = ReplaceKeys

public struct ReplaceKeys: CodingKeyMapping {
    
    /// You need to replace it with a new coding key.
    public var keyString: String
    
    /// The old coding key will be replaced.
    /// When multiple valid fields are mapped to the same property, the first one is used first.
    public let keys: [String]
    
    public init(replaceKey: String, originalKey: String...) {
        self.keyString = replaceKey
        self.keys = originalKey
    }
    
    public init(replaceKey: String, keys: [String]) {
        self.keyString = replaceKey
        self.keys = keys
    }
    
    public init(location: CodingKey, keys: String...) {
        self.keyString = location.stringValue
        self.keys = keys
    }
    
    public init(location: CodingKey, keys: [String]) {
        self.keyString = location.stringValue
        self.keys = keys
    }
    
    var hasNestedKeys: NestedKeys? {
        let keys = keys.filter {
            $0.contains(".")
        }
        if keys.isEmpty {
            return nil
        }
        return NestedKeys.init(replaceKey: keyString, keys: keys)
    }
    
    var hasNormalKeys: [String] {
        keys.filter {
            !$0.contains(".")
        }
    }
}

extension Collection where Element == ReplaceKeys {
    
    public var toDecoderingMappingKeys: Dictionary<String, String> {
        Dictionary(uniqueKeysWithValues: self.map({ a in
            a.hasNormalKeys.map { ($0, a.keyString) }
        }).reduce([], +))
    }
    
    public var toEncoderingMappingKeys: Dictionary<String, String> {
        Dictionary(uniqueKeysWithValues: self.compactMap {
            if let key = $0.hasNormalKeys.first {
                return ($0.keyString, key)
            } else {
                return nil
            }
        }.filterDuplicates({
            $0.0
        }))
    }
}
