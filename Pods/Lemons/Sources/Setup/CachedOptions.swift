//
//  CachedOptions.swift
//  Lemons
//
//  Created by Condy on 2023/3/30.
//

import Foundation

public struct CachedOptions: OptionSet, Hashable {
    /// Returns a raw value.
    public let rawValue: UInt16
    
    /// Initialializes options with a given raw values.
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    /// Do not use any cache.
    public static let none = CachedOptions(rawValue: 1 << 0)
    /// Cache the data in memory.
    public static let memory = CachedOptions(rawValue: 1 << 1)
    /// Cache the data in disk.
    public static let disk = CachedOptions(rawValue: 1 << 2)
    /// Use memory and disk cache at the same time to read memory first.
    public static let all: CachedOptions = [.memory, .disk]
}
