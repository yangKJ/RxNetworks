//
//  HandyJSONError.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation

@frozen public enum HandyJSONError: Swift.Error {
    case mapModel, mapArray
    case mapCode(Int)
}

extension HandyJSONError {
    internal var underlyingError: Swift.Error? {
        switch self {
        case .mapModel: return nil
        case .mapArray: return nil
        case .mapCode: return nil
        }
    }
}

extension HandyJSONError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .mapModel:
            return "Failed to map HandyJSON to an model."
        case .mapArray:
            return "Failed to map HandyJSON to an model array."
        case .mapCode(let code):
            return "Failed to map HandyJSON with code (\(code))."
        }
    }
}

// MARK: - Error User Info

extension HandyJSONError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
