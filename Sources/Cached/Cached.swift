//
//  Cached.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//  

import Foundation
import CoreFoundation

public final class Cached<T: Codable> {
    
    /// Disk storage tool.
    public var disk: Disk
    
    lazy var transformer = TransformerFactory.forCodable(ofType: T.self)
    
    private let backgroundQueue: DispatchQueue
    
    public init(queue: DispatchQueue? = nil) {
        self.disk = Disk()
        self.backgroundQueue = queue ?? {
            /// Create a background thread.
            DispatchQueue(label: "com.condy.rx.cached.queue", qos: .background, attributes: [.concurrent])
        }()
        self.disk.removeExpiredURLsFromDisk()
    }
    
    /// Caching object.
    public func storeCached(_ object: T, forKey key: String) {
        guard let data = try? transformer.toData(object) else {
            return
        }
        store(key: key, value: data)
    }
    
    /// Read cached object.
    public func fetchCached(forKey key: String) -> T? {
        /// 过期清除缓存
        if disk.isExpired(forKey: key), disk.removeObjectCache(key) {
            return nil
        }
        guard let data = read(key: key) else {
            return nil
        }
        return try? transformer.fromData(data)
    }
    
    /// Read disk data or memory data.
    public func read(key: String) -> Data? {
        if let data = Memory.memoryCacheData(key: key) {
            return data
        } else {
            return disk.diskCacheData(key: key)
        }
    }
    
    /// Asynchronous acquisition of cached data.
    public func asynchronousReadCachedData(key: String, complete: @escaping (_ data: Data?) -> Void) {
        backgroundQueue.async { [weak self] in
            let data = self?.read(key: key)
            complete(data)
        }
    }
    
    /// Storage data asynchronously to disk and memory.
    public func store(key: String, value: Data) {
        backgroundQueue.async { [weak self] in
            Memory.store2Memory(with: value, key: key)
            self?.disk.store2Disk(with: value, key: key)
        }
    }
    
    /// Remove disk cache and memory cache.
    public func removedDiskAndMemoryCached(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            Memory.removeAllMemoryCache()
            self?.disk.removeAllDiskCache { isSuccess in
                DispatchQueue.main.async { completion?(isSuccess) }
            }
        }
    }
}
