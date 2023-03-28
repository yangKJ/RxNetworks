//
//  CacheModel.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//  https://github.com/yangKJ/RxNetworks

import Foundation

struct CacheModel: Codable {
    var data: Data?
    var statusCode: Int?
    init() { }
}
