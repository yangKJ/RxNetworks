//
//  UserDefaults.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/5/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.rx.networks")
}

/// `UserDefaults`属性包裹器
///
///     @UserDefault_("root_manager_open_mourning_mode", defaultValue: false)
///     public static var mourning: Bool
@propertyWrapper public struct UserDefault_<T> {
    
    let key: String
    let defaultValue: T
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.group?.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.group?.set(newValue, forKey: key)
        }
    }
}
