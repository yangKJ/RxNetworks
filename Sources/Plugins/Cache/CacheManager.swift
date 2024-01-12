//
//  CacheManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`CacheX`文档
/// https://github.com/yangKJ/CacheX

import Foundation
import CoreFoundation
import CacheX

public struct CacheModel: Codable {
    let data: Data?
    let statusCode: Int?
}

public struct CacheManager {
    
    public static let `default` = CacheManager()
    
    public let storage: Storage<CacheModel>
    
    private init() {
        self.named = "RxNetworksCached"
        self.expiry = .seconds(60 * 60 * 24 * 7)
        self.maxCostLimit = 0
        self.maxCountLimit = 20 * 1024
        let background = DispatchQueue(label: "com.condy.rx.networks.cached.queue", attributes: [.concurrent])
        storage = Storage<CacheModel>.init(queue: background, caches: [
            Disk.named: Disk(),
            Memory.named: Memory(),
        ])
        if var disk = storage.caches[Disk.named] as? Disk {
            disk.named = self.named
            disk.expiry = self.expiry
            disk.maxCountLimit = self.maxCountLimit
            storage.caches.updateValue(disk, forKey: Disk.named)
        }
        if var memory = storage.caches[Memory.named] as? Memory {
            memory.maxCostLimit = self.maxCostLimit
            storage.caches.updateValue(memory, forKey: Memory.named)
        }
    }
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var named: String {
        didSet {
            if var disk = storage.caches[Disk.named] as? Disk {
                disk.named = named
                storage.caches.updateValue(disk, forKey: Disk.named)
            }
        }
    }
    
    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week ``60 * 60 * 24 * 7 seconds``.
    public var expiry: CacheX.Expiry {
        didSet {
            if var disk = storage.caches[Disk.named] as? Disk {
                disk.expiry = expiry
                storage.caches.updateValue(disk, forKey: Disk.named)
            }
        }
    }
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb.
    public var maxCountLimit: CacheX.Disk.Byte {
        didSet {
            if var disk = storage.caches[Disk.named] as? Disk {
                disk.maxCountLimit = maxCountLimit
                storage.caches.updateValue(disk, forKey: Disk.named)
            }
        }
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            if var memory = storage.caches[Memory.named] as? Memory {
                memory.maxCostLimit = maxCostLimit
                storage.caches.updateValue(memory, forKey: Memory.named)
            }
        }
    }
    
    /// Get the disk cache size.
    public var totalCost: UInt64 {
        mutating get {
            guard let disk = storage.caches[Disk.named] as? Disk else {
                return 0
            }
            return UInt64(disk.totalCost)
        }
    }
    
    /// Clear all caches.
    public func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) {
        storage.removedDiskAndMemoryCached(completion: completion)
    }
    
    /// Clear the cache according to key value.
    @discardableResult public func removeObjectCache(_ key: String) -> Bool {
        if let memory = storage.caches[Memory.named] as? Memory {
            let _ = memory.removeCache(key: key)
        }
        if let disk = storage.caches[Disk.named] as? Disk {
            return disk.removeCache(key: key)
        }
        return false
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
