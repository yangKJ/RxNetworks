//
//  CacheConvertable+Ext.swift
//  NetworkCachePlugin
//
//  Created by Condy on 2024/6/6.
//

import Foundation
import Booming
import CacheX

extension CacheX.Storage: CacheConvertable where T == Moya.Response {
    
    public func readResponse(forKey key: String) throws -> Moya.Response? {
        let key = CryptoType.md5.encryptedString(with: key)
        return self.fetchCached(forKey: key, options: .diskAndMemory)
    }
    
    public func saveResponse(_ response: Moya.Response, forKey key: String) throws {
        let key = CryptoType.md5.encryptedString(with: key)
        self.storeCached(response, forKey: key, options: .diskAndMemory)
    }
    
    public func clearAllResponses() {
        self.removedDiskAndMemoryCached()
    }
}
