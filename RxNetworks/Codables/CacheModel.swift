//
//  CacheModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HollowCodable

struct CacheModel: HollowCodable {
    
    var ip: String?
    var url: String?
    var data: String?
    
    @DictionaryCoding
    var headers: [String: Any]?
    
    /// 转换映射key
    static func mapping(mapper: HelpingMapper) {
        mapper <<< CodingKeys.ip <-- "origin"
        mapper <<< CodingKeys.url <-- "github"
    }
}
