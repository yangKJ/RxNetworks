//
//  Operators.swift
//  CodableExample
//
//  Created by Condy on 2024/7/4.
//

import Foundation

infix operator <-- : LogicalConjunctionPrecedence

/// Map the data fields corresponding to `keys` to model properties corresponding to `location`.
public func <-- (location: CodingKey, key: String) -> CodingKeyMapping {
    ReplaceKeys(location: location, keys: key)
}

public func <-- (replaceKey: String, key: String) -> CodingKeyMapping {
    ReplaceKeys(replaceKey: replaceKey, originalKey: key)
}

public func <-- (location: CodingKey, keys: [String]) -> CodingKeyMapping {
    ReplaceKeys(location: location, keys: keys)
}

public func <-- (replaceKey: String, keys: [String]) -> CodingKeyMapping {
    ReplaceKeys(replaceKey: replaceKey, keys: keys)
}

public func <-- (key: String, tranformer: any TransformType) -> CodingKeyMapping {
    TransformKeys(key: key, tranformer: tranformer)
}

public func <-- (location: CodingKey, tranformer: any TransformType) -> CodingKeyMapping {
    TransformKeys(location: location, tranformer: tranformer)
}

infix operator <<< : AssignmentPrecedence

public func <<< (mapper: HelpingMapper, mapping: CodingKeyMapping) {
    mapper.codingKeys.append(mapping)
}

public func <<< (mapper: HelpingMapper, mappings: [CodingKeyMapping]) {
    mapper.codingKeys += mappings
}
