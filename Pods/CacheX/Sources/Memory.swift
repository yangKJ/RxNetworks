//
//  Memory.swift
//  CacheX
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public struct Memory: Subscriptable {
    public typealias Key = NSString
    
    public typealias Value = NSData
    
    /// A singleton shared memory cache.
    private static let memory = NSCache<Key, Value>()
    private let lock = NSLock()
    private var cleanTimer: Timer?
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            Memory.memory.totalCostLimit = Int(maxCostLimit)
        }
    }
    
    /// The item count limit of the memory storage.
    public var countLimit: UInt = .max {
        didSet {
            Memory.memory.countLimit = Int(countLimit)
        }
    }
    
    public var evictsObjectsWithDiscardedContent: Bool = true {
        didSet {
            Memory.memory.evictsObjectsWithDiscardedContent = evictsObjectsWithDiscardedContent
        }
    }
    
    public init() { }
    
    public subscript(_ key: Key) -> Value? {
        get {
            return Memory.memory.object(forKey: key)
        }
        set {
            if let value = newValue, value.length > 0 {
                Memory.memory.setObject(value, forKey: key, cost: value.length)
            } else {
                Memory.memory.removeObject(forKey: key)
            }
        }
    }
}

extension Memory: Cacheable {
    
    public static var named: String {
        "CacheX_memory"
    }
    
    public func read(key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        let key = key as NSString
        guard let data = self[key] else {
            return nil
        }
        return Data(referencing: data)
    }
    
    public func store(key: String, value: Data) {
        lock.lock()
        let key = key as NSString
        Memory.memory.setObject(value as NSData, forKey: key, cost: value.count)
        lock.unlock()
    }
    
    @discardableResult public func removeCache(key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let key = key as NSString
        Memory.memory.removeObject(forKey: key)
        return true
    }
    
    public func removedCached(completion: SuccessComplete) {
        lock.lock()
        Memory.memory.removeAllObjects()
        lock.unlock()
        completion(true)
    }
}
