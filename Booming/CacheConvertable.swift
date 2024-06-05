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

public struct CacheXCodable: Codable {
    public let data: Data
    public let statusCode: Int
    
    public init(data: Data, statusCode: Int) {
        self.data = data
        self.statusCode = statusCode
    }
}

#if canImport(CacheX)

import CacheX

extension CacheX.Storage: CacheConvertable where T == CacheXCodable {
    
    public func readResponse(forKey key: String) throws -> Moya.Response? {
        let key = CryptoType.md5.encryptedString(with: key)
        guard let model = self.fetchCached(forKey: key, options: .diskAndMemory) else {
            return nil
        }
        return Response(statusCode: model.statusCode, data: model.data)
    }
    
    public func saveResponse(_ response: Moya.Response, forKey key: String) throws {
        let model = CacheXCodable(data: response.data, statusCode: response.statusCode)
        let key = CryptoType.md5.encryptedString(with: key)
        self.storeCached(model, forKey: key, options: .diskAndMemory)
    }
    
    public func clearAllResponses() {
        self.removedDiskAndMemoryCached()
    }
}

#endif
