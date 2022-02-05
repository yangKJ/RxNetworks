//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

///`YYCache`文档
/// https://github.com/ibireme/YYCache

import Foundation
import YYCache

public struct CacheManager {
    public static let name = "ykj.Network.cache.plugin"
    /// Maximum number of cache lines
    public static var maxCountLimit: UInt = 100
    /// Disk cache size, default 30m
    public static var maxCostLimit: UInt = 30 * 1024
}

extension CacheManager {
    
    /// Current cached size
    public static var totalCost: Int {
        if let cache = YYCache.init(name: CacheManager.name) {
            return cache.diskCache.totalCost()
        }
        return 0
    }
    
    /// The current number of cached items
    public static var totalCount: Int {
        if let cache = YYCache.init(name: CacheManager.name) {
            return cache.diskCache.totalCount()
        }
        return 0
    }
    
    /// Delete the disk cache
    public static func removeAllCache() {
        if let cache = YYCache.init(name: CacheManager.name) {
            cache.diskCache.removeAllObjects()
        }
    }
    
    /// Cache data
    /// - Parameters:
    ///   - dict: The cached object
    ///   - key: Cache key name
    public static func saveCacheWithDictionary(_ dict: NSDictionary, key: String) {
        if let cache = YYCache.init(name: CacheManager.name) {
            cache.memoryCache.countLimit = CacheManager.maxCountLimit
            cache.memoryCache.costLimit = CacheManager.maxCostLimit
            cache.setObject(dict, forKey: key)
        }
    }
    
    /// Read cache data
    /// - Parameter key: Cache key name
    /// - Returns: Cache object
    public static func fetchCachedWithKey(_ key: String) -> NSDictionary? {
        if let cache = YYCache.init(name: CacheManager.name) {
            return cache.object(forKey: key) as? NSDictionary
        }
        return nil
    }
}
