//
//  Operator.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/20.
//  https://github.com/yangKJ/RxNetworks

import Foundation

/// 字典拼接 `+=
/// Example
///
///     var dict1 = ["key": "1"]
///     let dict2 = ["key": "cdy", "Condy": "ykj310@126.com"]
///
///     dict1 += dict2
///
///     print("\(dict1)")
///     // Prints "["key": "cdy", "Condy": "ykj310@126.com"]"
///
public func += <K,V> (left: inout Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else { return }
    right.forEach { key, value in
        left.updateValue(value, forKey: key)
    }
}
