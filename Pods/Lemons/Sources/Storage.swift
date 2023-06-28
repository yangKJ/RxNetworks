//
//  Storage.swift
//  Lemons
//
//  Created by Condy on 2023/3/23.
//  

import Foundation

/// Mixed storge transfer station.
public final class Storage<T: Codable> {
    
    public lazy var disk: Disk = Disk()
    public lazy var memory: Memory = Memory()
    
    lazy var transformer = TransformerFactory.forCodable(ofType: T.self)
    public let backgroundQueue: DispatchQueue
    
    /// Initialize the object.
    /// - Parameter queue: The default thread is the background thread.
    public init(queue: DispatchQueue? = nil) {
        self.backgroundQueue = queue ?? {
            /// Create a background thread.
            DispatchQueue(label: "com.condy.lemons.cached.queue", qos: .background, attributes: [.concurrent])
        }()
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
        if options ~= .memory, let data = memory.read(key: key) {
            return data
        }
        if options ~= .disk, let data = disk.read(key: key) {
            return data
        }
        return nil
    }
    
    /// Write data asynchronously to disk and memory.
    public func write(key: String, value: Data, options: CachedOptions) {
        backgroundQueue.async {
            if options ~= .disk {
                self.disk.store(key: key, value: value)
            }
            if options ~= .memory {
                self.memory.store(key: key, value: value)
            }
        }
    }
    
    /// Remove the specified data.
    public func removed(forKey key: String, options: CachedOptions) {
        if options ~= .disk {
            self.disk.removeCache(key: key)
        }
        if options ~= .memory {
            self.memory.removeCache(key: key)
        }
    }
    
    /// Remove disk cache and memory cache.
    public func removedDiskAndMemoryCached(completion: SuccessComplete? = nil) {
        backgroundQueue.async {
            self.disk.removedCached { isSuccess in
                DispatchQueue.main.async { completion?(isSuccess) }
            }
            self.memory.removedAllCached()
        }
    }
}
