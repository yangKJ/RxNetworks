//
//  Deserialized.swift
//  RxNetworks
//
//  Created by Condy on 2023/12/25.
//  https://github.com/yangKJ/RxNetworks

import Foundation
@_exported import HandyJSON

/// Deserialized json converts to Model or Array.
public struct Deserialized<H> where H: HandyJSON {
    
    public static func toModel(with element: Any?) -> H? {
        if let string = element as? String, let model = H.deserialize(from: string) {
            return model
        }
        if let dictionary = element as? Dictionary<String, Any>, let model = H.deserialize(from: dictionary) {
            return model
        }
        if let dictionary = element as? [String : Any], let model = H.deserialize(from: dictionary) {
            return model
        }
        return nil
    }
    
    public static func toModel(with element: Any?, atKeyPath keyPath: String?) -> H? {
        if let string = element as? String, let model = Deserialized<H>.toModel(with: string) {
            return model
        }
        if let dictionary = element as? NSDictionary {
            if let keyPath = keyPath {
                let value = dictionary.value(forKeyPath: keyPath)
                if let model = Deserialized<H>.toModel(with: value) {
                    return model
                }
            } else if let model = Deserialized<H>.toModel(with: dictionary) {
                return model
            }
        }
        return nil
    }
    
    public static func toArray(with element: Any?) -> [H]? {
        if let string = element as? String, let array = [H].deserialize(from: string) as? [H] {
            return array
        }
        if let array = [H].deserialize(from: element as? [Any]) as? [H] {
            return array
        }
        return nil
    }
    
    public static func toArray(with element: Any?, atKeyPath keyPath: String?) -> [H]? {
        if let keyPath = keyPath, let dictionary = element as? NSDictionary {
            let value = dictionary.value(forKeyPath: keyPath)
            if let array = Deserialized<H>.toArray(with: value) {
                return array
            }
        }
        if let array = Deserialized<H>.toArray(with: element) {
            return array
        }
        return nil
    }
}
