//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import YYCache

public struct CacheManager {
    
    /// Maximum number of cache lines
    public static var maxCountLimit: UInt = 100
    /// Disk cache size, default 30m
    public static var maxCostLimit: UInt = 30 * 1024
}

extension CacheManager {
    
    public static var cache: YYCache? {
        return YYCache.init(name: NetworkCachePlugin.kCacheName)
    }
    
    /// Current cached size
    public static var totalCost: Int {
        if let cache = YYCache.init(name: NetworkCachePlugin.kCacheName) {
            return cache.diskCache.totalCost()
        }
        return 0
    }
    
    /// The current number of cached items
    public static var totalCount: Int {
        if let cache = YYCache.init(name: NetworkCachePlugin.kCacheName) {
            return cache.diskCache.totalCount()
        }
        return 0
    }
    
    /// Delete the disk cache
    public static func removeAllCache() {
        if let cache = YYCache.init(name: NetworkCachePlugin.kCacheName) {
            cache.diskCache.removeAllObjects()
        }
    }
}
