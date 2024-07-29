//
//  Hollow.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

/// 值得一提，这个库也挺不错的，采用宏的方式来实现，感兴趣可以去看看；
/// See: https://github.com/SwiftyLab/MetaCodable

import Foundation

public struct Hollow {
    
    public static func transfer2String(with value: Any?) -> String? {
        guard let value = value else {
            return nil
        }
        switch value {
        case let val as String:
            return val
        case let val as Bool:
            return val.description
        case let val as Double where val <= 9999999999999998:
            return val.hc.string(minPrecision: 2, maxPrecision: 16)
        case let val as Float:
            return String(describing: val)
        case let val as CGFloat:
            return String(describing: val)
        case let val as Int:
            return String(describing: val)
        case let val as Int8:
            return String(describing: val)
        case let val as Int16:
            return String(describing: val)
        case let val as Int32:
            return String(describing: val)
        case let val as Int64:
            return String(describing: val)
        case let val as UInt:
            return String(describing: val)
        case let val as UInt8:
            return String(describing: val)
        case let val as UInt16:
            return String(describing: val)
        case let val as UInt32:
            return String(describing: val)
        case let val as UInt64:
            return String(describing: val)
        case let val as NSNumber:
            // Boolean Type Inside
            if NSStringFromClass(type(of: val)) == "__NSCFBoolean" {
                return val.boolValue ? "true" : "false"
            }
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = false
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 16
            return formatter.string(from: val)
        case let val as Data:
            return val.description
        case let val as Date:
            return val.description
        case let val as NSDecimalNumber:
            return val.description
        case let val as Decimal:
            return val.description
        case let val as URL:
            return val.absoluteString
        case let val as UUID:
            return val.uuidString
        case _ as NSNull:
            return nil
        default:
            return nil
        }
    }
}
