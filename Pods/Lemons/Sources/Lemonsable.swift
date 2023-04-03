//
//  Lemonsable.swift
//  Lemons
//
//  Created by Condy on 2023/3/31.
//

import Foundation

public typealias SuccessComplete = ((_ isSuccess: Bool) -> Void)

public protocol Lemonsable {
    
    /// Read data.
    func read(key: String) -> Data?
    
    /// Storage the data.
    func store(key: String, value: Data)
    
    /// Clear the cache according to key value.
    func removeCache(key: String) -> Bool
    
    /// Clear the cache.
    func removedAllCached()
    
    /// Clear the cache.
    /// - Parameter completion: Complete the callback.
    func removedCached(completion: SuccessComplete)
}

extension Lemonsable {
    
    public func removedAllCached() {
        removedCached { _ in
            
        }
    }
}
