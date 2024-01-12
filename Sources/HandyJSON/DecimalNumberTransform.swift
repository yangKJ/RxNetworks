//
//  DecimalNumberTransform.swift
//  RxNetworks
//
//  Created by Condy on 2023/5/11.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import HandyJSON

// See: https://github.com/yangKJ/RxNetworks/blob/master/RxNetworks/Modules/Cache/CacheModel.swift

public struct DecimalNumberTransform: TransformType {
    public typealias Object = NSDecimalNumber
    public typealias JSON = String
    
    public init() { }
    
    public func transformFromJSON(_ value: Any?) -> NSDecimalNumber? {
        var decimal: NSDecimalNumber?
        if let string = toString(value), string.count > 0 {
            decimal = NSDecimalNumber(string: string)
        }
        if decimal == .notANumber {
            return nil
        }
        return decimal
    }
    
    public func transformToJSON(_ value: NSDecimalNumber?) -> String? {
        return value?.description
    }
}

extension DecimalNumberTransform {
    private func toString(_ any: Any?) -> String? {
        switch any {
        case let s as String:
            return s
        case let s as Double where s <= 9999999999999998:
            return String(describing: s)
        case let s as NSNumber:
            return s.stringValue
        case let s as Int64:
            return String(describing: s)
        case let s as Int:
            return String(describing: s)
        case let s as Float:
            return String(describing: s)
        case let s as CGFloat:
            return String(describing: s)
        default:
            return nil
        }
    }
}
