//
//  MappingCodable.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public protocol MappingCodable: Codable {
    /// Setup the coding key that needs to be replaced.
    static var codingKeys: [ReplaceKeys] { get }
}

extension MappingCodable {
    public static var codingKeys: [ReplaceKeys] {
        []
    }
}
