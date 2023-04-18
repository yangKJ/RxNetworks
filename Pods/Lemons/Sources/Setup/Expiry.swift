//
//  Expiry.swift
//  Lemons
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
    
    /// The data expires after an day.
    public static let day = Expiry.seconds(60 * 60 * 24)
    
    /// The data expires after an week.
    public static let week = Expiry.seconds(60 * 60 * 24 * 7)
    
    /// The data expires after an year.
    public static let year = Expiry.seconds(60 * 60 * 24 * 365)
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
