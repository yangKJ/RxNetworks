//
//  UsePriorityLevel.swift
//  Booming
//
//  Created by Condy on 2024/6/1.
//

import Foundation

/// 等级排序，不够你项目使用则自己去定义追加即可
public struct UsePriorityLevel: OptionSet, Hashable {
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension UsePriorityLevel {
    
    /// The highest level, priority use.
    public static let highest = UsePriorityLevel(rawValue: 1 << 999)
    
    public static let high = UsePriorityLevel(rawValue: 1 << 99)
    
    public static let medium = UsePriorityLevel(rawValue: 1 << 35)
    
    public static let low = UsePriorityLevel(rawValue: 1 << 8)
}
