//
//  HandyJSONError.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation

@frozen public enum HandyJSONError: Swift.Error {
    case error(Error)
    case mapModel
    case mapArray
    case mapCode(Int)
}

extension HandyJSONError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .error(err):
            return err.localizedDescription
        case .mapModel:
            return "Failed to map HandyJSON to an model."
        case .mapArray:
            return "Failed to map HandyJSON to an model array."
        case .mapCode(let code):
            return "Failed to map HandyJSON with code (\(code))."
        }
    }
    
    var underlyingError: Swift.Error? {
        switch self {
        case .error(let err):
            return err
        case .mapModel:
            return nil
        case .mapArray:
            return nil
        case .mapCode:
            return nil
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
