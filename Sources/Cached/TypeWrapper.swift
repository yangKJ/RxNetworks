//
//  TypeWrapper.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//

import Foundation

/// Used to wrap Codable object
struct TypeWrapper<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case object
    }
    
    let object: T
    
    init(object: T) {
        self.object = object
    }
}
