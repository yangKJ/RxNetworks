//
//  Expiry.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//  

import Foundation

public typealias TimeInterval = Foundation.TimeInterval

/// Helper enum to set the expiration date.
public enum Expiry {
    /// Cache will be expired in the nearest future.
    case never
    /// Cache will be expired in the specified amount of seconds.
    case seconds(TimeInterval)
}

extension Expiry {
    /// Checks if cached object is expired according to expiration date.
    func isExpired(_ lastAccessData: Date) -> Bool {
        switch self {
        case .never:
            return false
        case .seconds(let timeInterval):
            let expiredDate = Date(timeIntervalSinceNow: -timeInterval)
            return (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
        }
    }
}
