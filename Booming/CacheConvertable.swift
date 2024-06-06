//
//  CacheConvertable.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import Moya

/// Any caching schema that complies with the protocol can use the `NetworkCustomCachePlugin`.
public protocol CacheConvertable {
    
    func readResponse(forKey key: String) throws -> Moya.Response?
    
    func saveResponse(_ response: Moya.Response, forKey key: String) throws
    
    func clearAllResponses()
}
