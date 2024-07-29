//
//  HollowError.swift
//  CodableExample
//
//  Created by Condy on 2024/7/18.
//

import Foundation

public enum HollowError: Swift.Error {
    case invalidJSONObject
    case stringToData
    case dataToString
    case dateToString
    case toDictionary
    case toJSONString
    case unsupportedType
}

extension HollowError: CustomStringConvertible, LocalizedError {
    
    /// For each error type return the appropriate description.
    public var description: String {
        localizedDescription
    }
    
    public var errorDescription: String? {
        localizedDescription
    }
    
    /// A textual representation of `self`, suitable for debugging.
    public var localizedDescription: String {
        switch self {
        case .invalidJSONObject:
            return "This is an invalid JSON object."
        case .stringToData:
            return "Description Failed to convert the string to Data."
        case .dataToString:
            return "The data to string is nil."
        case .dateToString:
            return "The value to date is nil."
        case .toDictionary:
            return "Description Failed to convert to dictionary."
        case .toJSONString:
            return "Converted JSON string is nil."
        case .unsupportedType:
            return "The `CodableAnyValue` unsupported type."
        }
    }
    
    /// Depending on error type, returns an underlying `Error`.
    internal var underlyingError: Swift.Error? {
        switch self {
        case .invalidJSONObject:
            return nil
        case .stringToData:
            return nil
        case .dataToString:
            return nil
        case .dateToString:
            return nil
        case .toDictionary:
            return nil
        case .toJSONString:
            return nil
        case .unsupportedType:
            return nil
        }
    }
}

extension HollowError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
