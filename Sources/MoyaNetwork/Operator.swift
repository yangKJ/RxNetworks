//
//  Operator.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/20.
//  https://github.com/yangKJ/RxNetworks

import Foundation

precedencegroup AppendPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}
infix operator +== : AppendPrecedence

/// 字典拼接 `+=
/// Example
///
///     var dict1 = ["key": "1"]
///     let dict2 = ["key": "cdy", "Condy": "yangkj310@gmail.com"]
///
///     dict1 += dict2
///
///     print("\(dict1)")
///     // Prints "["key": "cdy", "Condy": "yangkj310@gmail.com"]"
///
public func += <K,V>(left: inout Dictionary<K,V>, right: Dictionary<K,V>?) {
    right?.forEach { left.updateValue($1, forKey: $0) }
}

/// 字典拼接 `+==
/// Example
///
///     let dict1 = ["key": "1"]
///     let dict2 = ["key": "cdy", "Condy": "yangkj310@gmail.com"]
///     let dict3 = ["xcs": "123"]
///
///     let dict = dict1 +== dict2 +== dict3
///
///     print(dict)
///     // Prints ["key": "cdy", "Condy": "yangkj310@gmail.com", "xcs": "123"]
///
public func +== <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>?) -> Dictionary<K,V> {
    var left_ = left
    right?.forEach { left_.updateValue($1, forKey: $0) }
    return left_
}

/// 数组拼接 `+==
/// Example
///
///     let arr1 = [1,2,3]
///     let arr2 = [5,7,8]
///
///     let arr = arr1 +== arr2
///
///     print(arr)
///     // Prints [1, 2, 3, 5, 7, 8]
///
public func +== <T>(left: [T], right: [T]?) -> [T] {
    guard let right = right else {
        return left
    }
    var left_ = left
    left_ += right
    return left_
}
