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
    /// The maximum number of objects the cache should hold. default 100
    public static var maxCountLimit: UInt = 100
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb
    public static var maxCostLimit: UInt = 20 * 1024
    /// The maximum expiry time of objects in cache.
    public static var maxAgeLimit: TimeInterval = TimeInterval(MAXFLOAT)
    /// The minimum free disk space (in bytes) which the cache should kept.
    public static var freeDiskSpaceLimit: UInt = 0
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
            cache.diskCache.countLimit = CacheManager.maxCountLimit
            cache.diskCache.costLimit = CacheManager.maxCostLimit
            cache.diskCache.ageLimit = CacheManager.maxAgeLimit
            cache.diskCache.freeDiskSpaceLimit = CacheManager.freeDiskSpaceLimit
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
