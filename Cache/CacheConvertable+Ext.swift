//
//  CacheConvertable+Ext.swift
//  NetworkCachePlugin
//
//  Created by Condy on 2024/6/6.
//

import Foundation
import Booming
import CacheX

extension CacheX.Storage: CacheConvertable where T == CacheXCodable {
    
    public func readResponse(forKey key: String) throws -> Moya.Response? {
        let key = CryptoType.md5.encryptedString(with: key)
        guard let model = self.fetchCached(forKey: key, options: .diskAndMemory) else {
            return nil
        }
        return Moya.Response(statusCode: model.statusCode, data: model.data)
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
