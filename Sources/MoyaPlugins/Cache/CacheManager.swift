//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import YYCache

public struct CacheManager {
    public struct Cache { }
    /// Maximum number of cache lines
    public static var maxCountLimit: UInt = 100
    /// Disk cache size, default 30m
    public static var maxCostLimit: UInt = 30 * 1024
}

extension CacheManager.Cache {
    public static let name = "ykj.Network.cache.plugin"
}

extension CacheManager {
    
    /// Current cached size
    public static var totalCost: Int {
        if let cache = YYCache.init(name: CacheManager.Cache.name) {
            return cache.diskCache.totalCost()
        }
        return 0
    }
    
    /// The current number of cached items
    public static var totalCount: Int {
        if let cache = YYCache.init(name: CacheManager.Cache.name) {
            return cache.diskCache.totalCount()
        }
        return 0
    }
    
    /// Delete the disk cache
    public static func removeAllCache() {
        if let cache = YYCache.init(name: CacheManager.Cache.name) {
            cache.diskCache.removeAllObjects()
        }
    }
}
