//
//  Memory.swift
//  Lemons
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public struct Memory: Subscriptable {
    public typealias Key = String
    
    public typealias Value = Data
    
    /// A singleton shared memory cache.
    private static let memory = NSCache<AnyObject, NSData>()
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            Memory.memory.totalCostLimit = Int(maxCostLimit)
        }
    }
    
    public init() { }
    
    public subscript(_ key: Key) -> Value? {
        get {
            return Memory.memory.object(forKey: key as AnyObject) as? Data
        }
        set {
            if let value = newValue {
                Memory.memory.setObject(value as NSData, forKey: key as AnyObject, cost: value.count)
            } else {
                Memory.memory.removeObject(forKey: key as AnyObject)
            }
        }
    }
}

extension Memory: Lemonsable {
    
    public func read(key: String) -> Data? {
        self[key]
    }
    
    public func store(key: String, value: Data) {
        self.mutating { $0[key] = value }
    }
    
    @discardableResult public func removeCache(key: String) -> Bool {
        self.mutating { $0[key] = nil }
        return true
    }
    
    public func removedCached(completion: SuccessComplete) {
        Memory.memory.removeAllObjects()
        completion(true)
    }
}

extension Memory {
    private func mutating(_ block: (inout Memory) -> Void) {
        var options = self
        block(&options)
    }
}
