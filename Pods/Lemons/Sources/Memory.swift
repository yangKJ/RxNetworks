//
//  Memory.swift
//  Lemons
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
    /// Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            Memory.memory.totalCostLimit = Int(maxCostLimit)
        }
    }
    
    public init() { }
}

extension Memory: Lemonsable {
    
    public func read(key: String) -> Data? {
        Memory.memory.object(forKey: key as AnyObject) as? Data
    }
    
    public func store(key: String, value: Data) {
        Memory.memory.setObject(value as NSData, forKey: key as AnyObject, cost: value.count)
    }
    
    public func removeCache(key: String) -> Bool {
        Memory.memory.removeObject(forKey: key as AnyObject)
        return true
    }
    
    public func removedCached(completion: SuccessComplete) {
        Memory.memory.removeAllObjects()
        completion(true)
    }
}
