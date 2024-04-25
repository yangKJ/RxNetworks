//
//  OCStorage.swift
//  CacheX
//
//  Created by Condy on 2023/4/8.
//

import Foundation
import ObjectiveC

struct StorageModel: Codable { }

/// Compatible with OC to use this cache library.
/// Some Swift methods, attributes, etc. Cannot be accessed in OC, so the bridge file is established.
@objc public final class OCStorage: NSObject {
    
    let storage: Storage<StorageModel>
    
    @objc public let backgroundQueue: DispatchQueue
    
    /// Initialize the object.
    /// - Parameter queue: The default thread is the background thread.
    @objc public init(queue: DispatchQueue) {
        self.backgroundQueue = queue
        self.storage = Storage(queue: backgroundQueue, options: .diskAndMemory)
        super.init()
    }
    
    @objc public override convenience init() {
        let queue = DispatchQueue(label: "com.condy.CacheX.objc.cached.queue", qos: .background, attributes: [.concurrent])
        self.init(queue: queue)
    }
    
    /// The name of disk storage, this will be used as folder name within directory.
    @objc public var named: String = "DiskCached" {
        didSet {
            disk?.named = named
        }
    }
    
    /// The longest time duration in second of the cache being stored in disk. default is an week.
    @objc public var maxAgeLimit: TimeInterval = 60 * 60 * 24 * 7 {
        didSet {
            disk?.expiry = Expiry.seconds(maxAgeLimit)
        }
    }
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb.
    @objc public var maxCountLimit: Disk.Byte = 20 * 1024 {
        didSet {
            disk?.maxCountLimit = maxCountLimit
        }
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Memory cache will be purged automatically when a memory warning notification is received.
    @objc public var maxCostLimit: UInt = 00 {
        didSet {
            memory?.maxCostLimit = maxCostLimit
        }
    }
    
    /// Read disk data or memory data.
    /// - Parameters:
    ///   - key: Cache key.
    ///   - options: Type of cache, default disk and memory.
    /// - Returns: Disk data or memory data.
    @objc public func read(key: String, options: OCCachedOptions) -> Data? {
        storage.read(key: key, options: options.options)
    }
    
    /// Read disk data or memory data.
    /// - Parameter key: Cache key.
    /// - Returns: Disk data or memory data.
    @objc public func read(key: String) -> Data? {
        read(key: key, options: .all)
    }
    
    /// Store data asynchronously to disk and memory.
    /// - Parameters:
    ///   - key: Cache key.
    ///   - value: Data to be cached.
    ///   - options: Type of cache, default disk and memory.
    @objc public func store(key: String, value: Data, options: OCCachedOptions) {
        storage.write(key: key, value: value, options: options.options)
    }
    
    /// Store data asynchronously to disk and memory.
    /// - Parameters:
    ///   - key: Cache key.
    ///   - value: Data to be cached.
    @objc public func store(key: String, value: Data) {
        store(key: key, value: value, options: .all)
    }
    
    /// Remove the data corresponding to the key.
    /// - Parameters:
    ///   - key: Cache key.
    ///   - options: Type of cache, default disk and memory.
    @objc public func removed(forKey key: String, options: OCCachedOptions = .all) {
        storage.removed(forKey: key, options: options.options)
    }
    
    /// Remove all caches.
    @objc public func removeAllCache() {
        storage.removedDiskAndMemoryCached()
    }
    
    /// Remove disk cache and memory cache.
    @objc public func removedDiskAndMemoryCached(completion: @escaping SuccessComplete) {
        storage.removedDiskAndMemoryCached(completion: completion)
    }
    
    private var disk: Disk? {
        get {
            return storage.caches[Disk.named] as? Disk
        }
        set {
            if let val = newValue {
                storage.caches.updateValue(val, forKey: Disk.named)
            }
        }
    }
    
    private var memory: Memory? {
        get {
            return storage.caches[Memory.named] as? Memory
        }
        set {
            if let val = newValue {
                storage.caches.updateValue(val, forKey: Memory.named)
            }
        }
    }
}

// MARK: - disk
extension OCStorage {
    /// Get the disk cache size.
    @objc public var totalCost: Disk.Byte {
        get {
            return disk?.totalCost ?? 0
        }
    }
    
    /// It's the file expired?
    @objc public func isExpired(forKey key: String) -> Bool {
        disk?.isExpired(forKey: key) ?? false
    }
    
    /// Remove expired files from disk.
    /// - Parameter completion: Removed file URLs callback.
    @objc public func removeExpiredURLsFromDisk(completion: ((_ expiredURLs: [URL]) -> Void)? = nil) {
        disk?.removeExpiredURLsFromDisk(completion: completion)
    }
}
