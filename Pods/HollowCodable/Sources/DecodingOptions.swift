//
//  DecodingOptions.swift
//  CodableExample
//
//  Created by Condy on 2024/7/18.
//

import Foundation

public struct DecodingOptions: OptionSet, RawRepresentable, Equatable, Hashable, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension DecodingOptions {
    /// Whether to allow parsing of JSON5.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public static let allowsJSON5 = DecodingOptions.init(rawValue: 1 << 0)
    
    /// Assume the data is a top level Dictionary (no surrounding "{ }" required). Compatible with both JSON5 and non-JSON5 mode.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public static let assumesTopLevelDictionary = DecodingOptions.init(rawValue: 1 << 1)
    
    /// Convert from `snake_case_keys` to `camelCaseKeys` before attempting to match a key with the one specified by each type.
    /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
    /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
    public static let CodingKeysConvertFromSnakeCase = DecodingOptions.init(rawValue: 1 << 2)
    
    /// Convert from `camelCaseKeys` to `snake_case_keys` before attempting to match a key with the one specified by each type.
    /// For example,  `oneTwoThree` becomes `one_two_three`.
    /// - Note: Using a key decoding strategy has a nominal performance cost.
    public static let CodingKeysConvertFromCamelCase = DecodingOptions.init(rawValue: 1 << 3)
    
    /// Convert the first letter of the key to lower case before attempting to match a key with the one specified by each type.
    /// For example, `OneTwoThree` becomes `oneTwoThree`.
    /// - Note: This strategy should be used with caution, especially if the key's first letter is intended to be uppercase for distinguishing purposes.
    /// It also incurs a nominal performance cost, as the first character of each key needs to be inspected and possibly modified.
    public static let CodingKeysConvertFirstLetterLower = DecodingOptions.init(rawValue: 1 << 4)
    
    /// Convert the first letter of the key to upper case before attempting to match a key with the one specified by each type.
    /// For example, `oneTwoThree` becomes `OneTwoThree`.
    /// - Note: This strategy should be used when the keys are expected to start with a lowercase letter and need to be converted to start with an uppercase letter. 
    /// It incurs a nominal performance cost, as the first character of each key needs to be inspected and possibly modified.
    public static let CodingKeysConvertFirstLetterUpper = DecodingOptions.init(rawValue: 1 << 5)
}

extension DecodingOptions {
    
    func hasCodingKeyConvertStrategy() -> Bool {
        return contains(.CodingKeysConvertFromSnakeCase)
        || contains(.CodingKeysConvertFromCamelCase)
        || contains(.CodingKeysConvertFirstLetterLower)
        || contains(.CodingKeysConvertFirstLetterUpper)
    }
}
