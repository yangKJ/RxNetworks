//
//  NestedKeys.swift
//  CodableExample
//
//  Created by Condy on 2024/7/24.
//

import Foundation

struct NestedKeys: CodingKeyMapping {
    
    /// You need to replace it with a new coding key.
    var keyString: String
    
    /// The old coding key will be replaced.
    /// When multiple valid fields are mapped to the same property, the first one is used first.
    let keys: [String]
    
    init(replaceKey: String, keys: String...) {
        self.keyString = replaceKey
        self.keys = keys
    }
    
    init(replaceKey: String, keys: [String]) {
        self.keyString = replaceKey
        self.keys = keys
    }
    
    init(location: CodingKey, keys: String...) {
        self.keyString = location.stringValue
        self.keys = keys
    }
    
    init(location: CodingKey, keys: [String]) {
        self.keyString = location.stringValue
        self.keys = keys
    }
    
    var hasPathCodingKeys: [[PathCodingKey]] {
        keys.map {
            $0.split(separator: ".").map {
                PathCodingKey(stringValue: String($0))
            }
        }
    }
}
