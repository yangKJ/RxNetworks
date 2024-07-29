//
//  LoadingModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2024/1/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import HollowCodable

struct LoadingModel: HollowCodable {
    @BoolCoding var hasMore: Bool?
    var responseCount: Int?
    var ctime: Date?
    var results: [Results]?
    
    static func mapping(mapper: HelpingMapper) {
        //mapper <<< CodingKeys.responseCount <-- "response_count"
        //mapper <<< CodingKeys.hasMore <-- "has_more"
        mapper <<< CodingKeys.ctime <-- TimestampDateTransform.init(type: .seconds)
    }
    
    struct Results: HollowCodable {
        var tplName: String?
        var type: String?
        @DictionaryCoding
        var content: [String: Any]?
    }
}
