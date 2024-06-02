//
//  FormatterConverter.swift
//  HollowCodable
//
//  Created by Condy on 2024/5/20.
//

import Foundation

public protocol FormatterConverter {
    func string(from date: Date) -> String
    func date(from string: String) -> Date?
}
