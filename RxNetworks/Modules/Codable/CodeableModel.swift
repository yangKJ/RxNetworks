//
//  CodeableModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HollowCodable

struct CodeableModel: Codable, MappingCodable {
    var id: Int
    var title: String?
    var imageURL: URL?
    
    var url: URL?
    
    @CodingBool
    var bar: Bool?
    
    @CodingSince1970Date
    var timestamp: Date?
    
    @CodingDateFormatter<Hollow.DateFormat.yyyy_mm_dd_hh_mm_ss>
    var time: Date?
    
    @CodingISO8601Date
    var iso8601: Date?
    
    @CodingHexColor
    var color: HollowColor?
    
    @CodingEnum<TextEnumType>
    var type: TextEnumType?
    
    @CodingDecimalNumber
    var amount: NSDecimalNumber?
    
    var dict: DictAA?
    
    struct DictAA: Codable {
        @CodingDecimalNumber
        var amount: NSDecimalNumber?
    }
    
    static var codingKeys: ReplaceKeys {
        return [
            ("color", "hex_color"),
            ("url", "github"),
        ]
    }
}

enum TextEnumType: String {
    case text1 = "text1"
    case text2 = "text2"
}
