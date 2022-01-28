//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation

public struct CacheManager {
    /// Maximum number of cache lines
    public static var maxCountLimit: Int = 100
    /// Disk cache size, default 30m
    public static var maxCostLimit: Int = 30 * 1024
    
    private let cache = { () -> NSCache<AnyObject, AnyObject> in
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = CacheManager.maxCountLimit
        cache.totalCostLimit = CacheManager.maxCostLimit
        return cache
    }()
}

extension CacheManager {
    
    /// Delete the disk cache
    public static func removeAllCache() {
        CacheManager().cache.removeAllObjects()
    }
    
    /// Delete the specified key data
    /// - Parameter key: Cache key name
    public static func deleteCacheWithKey(_ key: String) {
        CacheManager().cache.removeObject(forKey: key as AnyObject)
    }
    
    /// cache data
    /// - Parameters:
    ///   - dict: The cached object
    ///   - key: Cache key name
    public static func saveCacheWithDictionary(_ dict: NSDictionary, key: String) {
        CacheManager().cache.setObject(dict, forKey: key as AnyObject)
    }
    
    /// Read cache data
    /// - Parameter key: Cache key name
    /// - Returns: Cache object
    public static func fetchCachedWithKey(_ key: String) -> NSDictionary? {
        guard let data = CacheManager().cache.object(forKey: key as AnyObject) else {
            return nil
        }
        return data as? NSDictionary
    }
}
