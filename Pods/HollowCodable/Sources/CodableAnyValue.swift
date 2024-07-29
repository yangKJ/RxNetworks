//
//  CodableAnyValue.swift
//  CodableExample
//
//  Created by Condy on 2024/6/24.
//

import Foundation

public indirect enum CodableAnyValue: Codable {
    case null
    case bool(Bool)
    case int(Int)
    case uInt(UInt)
    case float(Float)
    case double(Double)
    case string(String)
    case url(URL)
    case uuid(UUID)
    case date(Date)
    case data(Data)
    case decimal(Decimal)
    case array([CodableAnyValue])
    case dictionary([String: CodableAnyValue])
}

extension CodableAnyValue {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
            return
        }
        if let int = try? container.decode(Int.self) {
            self = .int(int)
            return
        }
        if let uInt = try? container.decode(UInt.self) {
            self = .uInt(uInt)
            return
        }
        if let float = try? container.decode(Float.self) {
            self = .float(float)
            return
        }
        if let double = try? container.decode(Double.self) {
            self = .double(double)
            return
        }
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let date = try? container.decode(Date.self) {
            self = .date(date)
            return
        }
        if let data = try? container.decode(Data.self) {
            self = .data(data)
            return
        }
        if let url = try? container.decode(URL.self) {
            self = .url(url)
            return
        }
        if let uuid = try? container.decode(UUID.self) {
            self = .uuid(uuid)
            return
        }
        if let array = try? container.decode([CodableAnyValue].self) {
            self = .array(array)
            return
        }
        if let dict = try? container.decode([String: CodableAnyValue].self) {
            self = .dictionary(dict)
            return
        }
        throw HollowError.unsupportedType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .dictionary(let dict):
            try container.encode(dict)
        case .array(let array):
            try container.encode(array)
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .uInt(let uInt):
            try container.encode(uInt)
        case .float(let float):
            try container.encode(float)
        case .bool(let bool):
            try container.encode(bool)
        case .double(let double):
            try container.encode(double)
        case .date(let date):
            try container.encode(date)
        case .data(let data):
            try container.encode(data)
        case .uuid(let uuid):
            try container.encode(uuid)
        case .url(let url):
            try container.encode(url)
        case .decimal(let decimal):
            try container.encode(decimal)
        }
    }
}

extension CodableAnyValue {
    var value: Any? {
        switch self {
        case .null:
            return nil
        case .dictionary(let value):
            return value
        case .array(let value):
            return value
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .uInt(let value):
            return value
        case .float(let value):
            return value
        case .bool(let value):
            return value
        case .double(let value):
            return value
        case .date(let value):
            return value
        case .data(let value):
            return value
        case .uuid(let value):
            return value
        case .url(let value):
            return value
        case .decimal(let value):
            return value
        }
    }
    
    init?(value: Any) {
        switch value {
        case Optional<Any>.none:
            self = .null
        case is Void:
            self = .null
        case let val as String:
            self = .string(val)
        case let val as Int:
            self = .int(val)
        case let val as UInt:
            self = .uInt(val)
        case let val as Float:
            self = .float(val)
        case let val as Bool:
            self = .bool(val)
        case let val as Double:
            self = .double(val)
        case let val as Data:
            self = .data(val)
        case let val as Date:
            self = .date(val)
        case let val as UUID:
            self = .uuid(val)
        case let val as URL:
            self = .url(val)
        case let val as Decimal:
            self = .decimal(val)
        case let val as [CodableAnyValue]:
            self = .array(val)
        case let val as [String: CodableAnyValue]:
            self = .dictionary(val)
        default:
            return nil
        }
    }
}
