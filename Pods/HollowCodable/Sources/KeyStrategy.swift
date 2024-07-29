//
//  KeyStrategy.swift
//  CodableExample
//
//  Created by Condy on 2024/6/16.
//

import Foundation

extension JSONEncoder {
    
    func setupKeyStrategy<T: HollowCodable>(_ type: T.Type) {
        let mapper = HelpingMapper.setupCodingKeyMappingKeys(type)
        if !mapper.replaceKeys.isEmpty {
            let keys = mapper.replaceKeys.toEncoderingMappingKeys
            self.keyEncodingStrategy = .custom({ codingPath in
                let key = codingPath.last!.stringValue
                return PathCodingKey(stringValue: keys[key] ?? key)
            })
        }
        if !mapper.dateKeys.isEmpty {
            self.dateEncodingStrategy = .custom({ date, encoder in
                try mapper.dateKeys.first(where: {
                    $0.keyString == encoder.codingPath.last!.stringValue
                })?.encodingStrategy(with: encoder, value: date)
            })
        }
        if !mapper.dataKeys.isEmpty {
            self.dataEncodingStrategy = .custom({ data, encoder in
                try mapper.dataKeys.first(where: {
                    $0.keyString == encoder.codingPath.last!.stringValue
                })?.encodingStrategy(with: encoder, value: data)
            })
        }
    }
}

extension JSONDecoder {
    
    func setupKeyStrategy<T: HollowCodable>(_ type: T.Type, options: DecodingOptions) -> [NestedKeys] {
        let mapper = HelpingMapper.setupCodingKeyMappingKeys(type)
        if !mapper.replaceKeys.isEmpty || options.hasCodingKeyConvertStrategy() {
            let keys = mapper.replaceKeys.toDecoderingMappingKeys
            self.keyDecodingStrategy = .custom({ codingPath in
                var key = codingPath.last!.stringValue
                if let key_ = keys[key] {
                    key = key_
                } else if options.contains(.CodingKeysConvertFromSnakeCase) {
                    key = key.hc.snakeToCamel()
                } else if options.contains(.CodingKeysConvertFromCamelCase) {
                    key = key.hc.camelToSnake()
                } else if options.contains(.CodingKeysConvertFirstLetterLower) {
                    key = key.hc.firstLetterToLowercase()
                } else if options.contains(.CodingKeysConvertFirstLetterUpper) {
                    key = key.hc.firstLetterToUppercase()
                }
                return PathCodingKey(stringValue: key)
            })
        }
        if !mapper.dateKeys.isEmpty {
            self.dateDecodingStrategy = .custom({ decoder in
                if let date = mapper.dateKeys.first(where: {
                    $0.keyString == decoder.codingPath.last!.stringValue
                })?.decodingStrategyDate(with: decoder) {
                    return date
                }
                let container = try decoder.singleValueContainer()
                let des = "Cannot decode an date instance of Date"
                let decodingError = DecodingError.dataCorruptedError(in: container, debugDescription: des)
                if Hollow.Logger.logIfNeeded {
                    Hollow.Logger.logDebug(decodingError)
                }
                throw decodingError
            })
        }
        if !mapper.dataKeys.isEmpty {
            self.dataDecodingStrategy = .custom({ decoder in
                if let data = mapper.dataKeys.first(where: {
                    $0.keyString == decoder.codingPath.last!.stringValue
                })?.decodingStrategyData(with: decoder) {
                    return data
                }
                let container = try decoder.singleValueContainer()
                let des = "Cannot decode an data instance of Data"
                let decodingError = DecodingError.dataCorruptedError(in: container, debugDescription: des)
                if Hollow.Logger.logIfNeeded {
                    Hollow.Logger.logDebug(decodingError)
                }
                throw decodingError
            })
        }
        return mapper.nestedKeys
    }
}
