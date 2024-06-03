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
    @Immutable
    var id: Int
    var title: String?
    var imageURL: URL?
    
    var url: URL?
    
    @Immutable @BoolCoding
    var bar: Bool?
    
    @SecondsSince1970DateCoding
    var timestamp: Date?
    
    @DateFormatCoding<Hollow.DateFormat.yyyy_mm_dd_hh_mm_ss>
    var time: Date?
    
    @ISO8601DateCoding
    var iso8601: Date?
    
    @HexColorCoding
    var color: HollowColor?
    
    @EnumCoding<TextEnumType>
    var type: TextEnumType?
    
    @DecimalNumberCoding
    var amount: NSDecimalNumber?
    
    var dict: DictAA?
    
    struct DictAA: Codable {
        @DecimalNumberCoding
        var amount: NSDecimalNumber?
    }
    
    static var codingKeys: [ReplaceKeys] {
        return [
            ReplaceKeys.init(replaceKey: "color", originalKey: "hex_color"),
            ReplaceKeys.init(replaceKey: "url", originalKey: "github"),
        ]
    }
}

enum TextEnumType: String {
    case text1 = "text1"
    case text2 = "text2"
}
