//
//  Decoder+Ext.swift
//  CodableExample
//
//  Created by Condy on 2024/7/24.
//

import Foundation

extension Hollow {
    static let keyPathKey = CodingUserInfoKey(rawValue: "keyPath")!
}

extension JSONDecoder {
    
    var hasNestedKeys: [NestedKeys] {
        get {
            return userInfo[Hollow.keyPathKey] as? [NestedKeys] ?? []
        }
        set {
            userInfo[Hollow.keyPathKey] = newValue
        }
    }
}

extension Decoder {
    
    var hasNestedKeys: [NestedKeys]? {
        return userInfo[Hollow.keyPathKey] as? [NestedKeys]
    }
}
