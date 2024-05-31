//
//  Encodable+Ext.swift
//  Hollow
//
//  Created by Condy on 2024/5/20.
//

import Foundation

extension Encodable {
    
    public func toJSONString(prettyPrint: Bool = false) throws -> String {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        let jsonData = try encoder.encode(self)
        return String(decoding: jsonData, as: UTF8.self)
    }
}
