//
//  CacheXCodable.swift
//  NetworkCachePlugin
//
//  Created by Condy on 2024/6/6.
//

import Foundation

public struct CacheXCodable: Codable {
    public let data: Data
    public let statusCode: Int
    
    public init(data: Data, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }
}
