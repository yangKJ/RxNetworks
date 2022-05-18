//
//  CacheModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON

struct CacheModel: HandyJSON {
    
    var id : Int?
    var title : String?
    var imageURL : String?
    var url : String?
    
    /// 转换映射key
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            url <-- "github"
        mapper <<<
            imageURL <-- "image"
    }
}
