//
//  CacheModel.swift
//  Lemons
//
//  Created by Condy on 2023/3/30.
//

import Foundation

public struct CacheModel: Codable {
    public var data: Data?
    public var statusCode: Int?
    
    public init(data: Data? = nil, statusCode: Int? = nil) {
        self.data = data
        self.statusCode = statusCode
    }
}
