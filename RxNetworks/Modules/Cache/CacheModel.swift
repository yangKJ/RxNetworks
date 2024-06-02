//
//  CacheModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON
import RxNetworks

struct CacheModel: HandyJSON {
    
    var ip: String?
    var url: String?
    var data: String?
    
    /// 转换映射key
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            ip <-- "origin"
        mapper <<<
            url <-- "github"
    }
}
