//
//  CodableISO8601Date.swift
//  Booming
//
//  Created by Condy on 2024/5/31.
//

import Foundation

@propertyWrapper public struct CodableISO8601Date: Codable {
    
    public let wrappedValue: Date?
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    public init(from decoder: Decoder) throws {
        if let timeInterval = try? TimeInterval(from: decoder) {
            self.wrappedValue = self.dateFormatter.date(from: "\(timeInterval)")
        } else if let dateString = try? String(from: decoder) {
            self.wrappedValue = self.dateFormatter.date(from: dateString)
        } else {
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = self.wrappedValue {
            try container.encode(self.dateFormatter.string(from: date))
        } else {
            try container.encodeNil()
        }
    }
}
