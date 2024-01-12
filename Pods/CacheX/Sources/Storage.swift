//
//  Storage.swift
//  CacheX
//
//  Created by Condy on 2023/3/23.
//

import Foundation

/// Mixed storge transfer station.
public final class Storage<T: Codable> {
    
    public var caches: [String: Cacheable]
    public let backgroundQueue: DispatchQueue
    
    lazy var transformer = TransformerFactory<T>.forCodable()
    
    /// Initialize the object.
    /// - Parameter queue: The default thread is the background thread.
    public init(queue: DispatchQueue? = nil, caches: [String: Cacheable]) {
        self.backgroundQueue = queue ?? {
            /// Create a background thread.
            DispatchQueue(label: "com.condy.CacheX.cached.queue", attributes: [.concurrent])
        }()
        self.caches = caches
    }
    
    public convenience init(queue: DispatchQueue? = nil) {
        self.init(queue: queue, caches: CachedOptions.all.caches())
    }
    
    public convenience init(queue: DispatchQueue? = nil, options: CachedOptions) {
        self.init(queue: queue, caches: options.caches())
    }
    
    /// Caching object.
    public func storeCached(_ object: T, forKey key: String, options: CachedOptions) {
        guard let data = try? transformer.toData(object) else {
            return
        }
        write(key: key, value: data, options: options)
    }
    
    /// Read cached object.
    public func fetchCached(forKey key: String, options: CachedOptions) -> T? {
        guard let data = read(key: key, options: options) else {
            return nil
        }
        return try? transformer.fromData(data)
    }
    
    /// Read disk data or memory data.
    public func read(key: String, options: CachedOptions) -> Data? {
        for named in options.cacheNameds() {
            guard let value = self.caches[named]?.read(key: key) else {
                continue
            }
            return value
        }
        return nil
    }
    
    /// Write data asynchronously to disk and memory.
    public func write(key: String, value: Data, options: CachedOptions) {
        backgroundQueue.async {
            for named in options.cacheNameds() {
                self.caches[named]?.store(key: key, value: value)
            }
        }
    }
    
    /// Remove the specified data.
    public func removed(forKey key: String, options: CachedOptions) {
        for named in options.cacheNameds() {
            self.caches[named]?.removeCache(key: key)
        }
    }
    
    /// Remove disk cache and memory cache.
    public func removedDiskAndMemoryCached(completion: SuccessComplete? = nil) {
        backgroundQueue.async {
            if let disk = self.caches[Disk.named] {
                disk.removedCached { isSuccess in
                    DispatchQueue.main.async { completion?(isSuccess) }
                }
            }
            if let memory = self.caches[Memory.named] {
                memory.removedAllCached()
            }
        }
    }
}

/// 暂时兼容以前版本，未来将被废弃⚠️
extension Storage {
    public var disk: Disk? {
        get {
            return caches[Disk.named] as? Disk
        }
        set {
            if let val = newValue {
                caches.updateValue(val, forKey: Disk.named)
            }
        }
    }
    
    public var memory: Memory? {
        get {
            return caches[Memory.named] as? Memory
        }
        set {
            if let val = newValue {
                caches.updateValue(val, forKey: Memory.named)
            }
        }
    }
}
