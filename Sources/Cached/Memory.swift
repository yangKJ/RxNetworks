//
//  Memory.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public struct Memory {
    /// A singleton shared memory cache.
    static var memory: NSCache<AnyObject, AnyObject> {
        struct SharedCache {
            static var shared: NSCache<AnyObject, AnyObject> = NSCache()
        }
        return SharedCache.shared
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a memory warning notification is received.
    public static var maxCountLimit: UInt = 0 {
        didSet {
            Memory.memory.totalCostLimit = Int(maxCountLimit)
        }
    }
    
    /// Clear the memory cache.
    public static func removeAllMemoryCache() {
        Memory.memory.removeAllObjects()
    }
    
    /// Clear the cache according to key value.
    public func removeObjectCache(_ key: String) {
        Memory.memory.removeObject(forKey: key as AnyObject)
    }
    
    public static func memoryCacheData(key: String) -> Data? {
        return Memory.memory.object(forKey: key as AnyObject) as? Data
    }
    
    public static func store2Memory(with data: Data, key: String) {
        Memory.memory.setObject(data as NSData, forKey: key as AnyObject, cost: data.count)
    }
}
