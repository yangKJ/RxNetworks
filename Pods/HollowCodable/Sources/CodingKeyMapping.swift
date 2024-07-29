//
//  CodingKeyMapping.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

public protocol CodingKeyMapping {
    /// You need to replace it with a new coding key.
    var keyString: String { get set }
}

extension CodingKeyMapping {
    
    public var key: CodingKey {
        PathCodingKey(stringValue: keyString)
    }
}
