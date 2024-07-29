//
//  Converter.swift
//  CodableExample
//
//  Created by Condy on 2024/6/22.
//

import Foundation

/// Contract for providing a default value of a Type.
public protocol Converter {
    
    associatedtype Value
    associatedtype FromValue
    associatedtype ToValue
    
    static var hasValue: Value { get }
    
    static func transformToValue(with value: FromValue) -> ToValue?
    
    static func transformFromValue(with value: ToValue) -> FromValue?
}

extension Converter {
    
    public static func transformToValue(with value: FromValue) -> ToValue? {
        return nil
    }
    
    public static func transformFromValue(with value: ToValue) -> FromValue? {
        return nil
    }
}

public protocol DateConverter: Converter where FromValue == Date, ToValue == String { }

public protocol DataConverter: Converter where FromValue == Data, ToValue == String { }
