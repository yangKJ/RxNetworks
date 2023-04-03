//
//  Transformer.swift
//  Lemons
//
//  Created by Condy on 2023/3/23.
//  

import Foundation

struct Transformer<T> {
    let toData: (T) throws -> Data
    let fromData: (Data) throws -> T
    
    init(toData: @escaping (T) throws -> Data, fromData: @escaping (Data) throws -> T) {
        self.toData = toData
        self.fromData = fromData
    }
}
