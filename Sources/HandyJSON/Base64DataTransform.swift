//
//  Base64DataTransform.swift
//  RxNetworks
//
//  Created by Condy on 2023/5/20.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import HandyJSON

public struct Base64DataTransform: TransformType {
    public typealias Object = Data
    public typealias JSON = String
    
    public init() { }
    
    public func transformFromJSON(_ value: Any?) -> Data? {
        guard let string = value as? String else{
            return nil
        }
        return Data(base64Encoded: string)
    }
    
    public func transformToJSON(_ value: Data?) -> String? {
        guard let data = value else{
            return nil
        }
        return data.base64EncodedString()
    }
}
