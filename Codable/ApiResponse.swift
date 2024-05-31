//
//  ApiResponse.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public struct ApiResponse<T: Codable>: Codable {
    public var code: Int
    public var message: String?
    public var data: T?
    
    public var isSuccess: Bool {
        return 200 ..< 300 ~= code
    }
    
    public init(code: Int = -100010, message: String? = nil, data: T? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
