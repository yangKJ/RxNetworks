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
import Lemons

public struct CacheManager {
    
    public static let `default` = CacheManager()
    
    public let storage: Storage<CacheModel>
    
    private init() {
        self.named = "RxNetworksCached"
        self.expiry = .seconds(60 * 60 * 24 * 7)
        self.maxCostLimit = 0
        self.maxCountLimit = 20 * 1024
        let background = DispatchQueue(label: "com.condy.rx.networks.cached.queue", qos: .background, attributes: [.concurrent])
        storage = Storage<CacheModel>.init(queue: background)
        storage.disk.named = self.named
        storage.disk.expiry = self.expiry
        storage.disk.maxCountLimit = self.maxCountLimit
        storage.memory.maxCostLimit = self.maxCostLimit
    }
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var named: String {
        didSet {
            storage.disk.named = named
        }
    }
    
    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week ``60 * 60 * 24 * 7 seconds``.
    public var expiry: Lemons.Expiry {
        didSet {
            storage.disk.expiry = expiry
        }
    }
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb.
    public var maxCountLimit: Lemons.Disk.Byte {
        didSet {
            storage.disk.maxCountLimit = maxCountLimit
        }
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            storage.memory.maxCostLimit = maxCostLimit
        }
    }
    
    /// Get the disk cache size.
    public var totalCost: UInt64 {
        mutating get {
            return UInt64(storage.disk.totalCost)
        }
    }
    
    /// Clear all caches.
    public func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) {
        storage.removedDiskAndMemoryCached(completion: completion)
    }
    
    /// Clear the cache according to key value.
    @discardableResult public func removeObjectCache(_ key: String) -> Bool {
        let _ = storage.memory.removeCache(key: key)
        return storage.disk.removeCache(key: key)
    }
    
    /// Read disk data or memory data.
    public func read(key: String) -> Data? {
        storage.read(key: key, options: .all)
    }
    
    /// Storage data asynchronously to disk and memory.
    public func store(key: String, value: Data) {
        storage.write(key: key, value: value, options: .all)
    }
}
