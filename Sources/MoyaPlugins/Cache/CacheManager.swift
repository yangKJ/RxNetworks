//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`Cache`文档
/// https://github.com/hyperoslo/Cache

import Foundation
import CoreFoundation

public struct CacheManager {
    
    public static var `default` = CacheManager()
    
    let storage: Cached<CacheModel>
    
    private init() {
        self.named = "RxNetworksCached"
        self.expiry = .seconds(60 * 60 * 24 * 7)
        self.storage = Cached<CacheModel>()
        self.storage.disk.named = named
        self.storage.disk.expiry = expiry
        self.storage.disk.maxCostLimit = 0
        Memory.maxCountLimit = 0
    }
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var named: String {
        didSet {
            storage.disk.named = named
        }
    }
    
    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week ``60 * 60 * 24 * 7 seconds``.
    public var expiry: Expiry {
        didSet {
            storage.disk.expiry = expiry
        }
    }
    
    /// The largest disk size can be taken for the cache. It is the total allocated size of cached files in bytes. Default is no limit.
    public var maxCostLimit: UInt = 0 {
        didSet {
            storage.disk.maxCostLimit = maxCostLimit
        }
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCountLimit: UInt = 0 {
        didSet {
            Memory.maxCountLimit = maxCountLimit
        }
    }
    
    /// Get the disk cache size.
    public var totalCost: UInt64 {
        mutating get {
            return storage.disk.totalCost
        }
    }
    
    /// Clear all caches.
    public mutating func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) {
        Memory.removeAllMemoryCache()
        storage.disk.removeAllDiskCache(completion: completion)
    }
    
    /// Clear the cache according to key value.
    @discardableResult public mutating func removeObjectCache(_ key: String) -> Bool {
        storage.disk.removeObjectCache(key)
    }
    
    /// Read disk data or memory data.
    public mutating func read(key: String) -> Data? {
        storage.read(key: key)
    }
    
    /// Storage data asynchronously to disk and memory.
    public mutating func store(key: String, value: Data) {
        storage.store(key: key, value: value)
    }
}

extension CacheManager {
    /// Asynchronous cached.
    mutating func saveCached(_ object: CacheModel, forKey key: String) {
        storage.storeCached(object, forKey: key)
    }
    
    /// Read cached object.
    mutating func fetchCached(forKey key: String) -> CacheModel? {
        storage.fetchCached(forKey: key)
    }
}
