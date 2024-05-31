//
//  HollowCodeable.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Booming

struct HollowCodeable: Codable {
    var id: Int
    var title: String?
    var imageURL: URL?
    var url: URL?
    
    @CodableBool
    var bar: Bool?
    
    @CodableSince1970Date<Interval.milliseconds>
    var immutableTime: Date?
    
    @CodableDateFormatter<DateFormat.yyyy_mm_dd_hh_mm_ss>
    var time: Date?
    
    @CodableHexColor
    var hex: BoomingColor?
    
    @CodableEnum<TextEnumType>
    var type: TextEnumType?
    
    @CodableDecimalNumber
    var amount: NSDecimalNumber?
    
//    var color: UIColor?
//
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.title = try container.decodeIfPresent(String.self, forKey: .title)
//        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
//        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
//        self.color = try container.decodeIfPresent(UIColor.self, forKey: .color)
//        self.amount = try container.decodeIfPresent(NSDecimalNumber.self, forKey: .amount)
//        self.type = try container.decodeIfPresent(TextEnumType.self, forKey: .type)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case imageURL
//        case color = "hex"
//        case url = "github"
//        case type
//        case amount
//    }
//
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encodeIfPresent(self.title, forKey: .title)
//        try container.encodeIfPresent(self.imageURL, forKey: .imageURL)
//        try container.encodeIfPresent(self.url, forKey: .url)
//        try container.encodeIfPresent(self.color, forKey: .color)
//        try container.encodeIfPresent(self.amount, forKey: .amount)
//        try container.encodeIfPresent(self.type, forKey: .type)
//    }
}

enum TextEnumType: String {
    case text1 = "text1"
    case text2 = "text2"
}
