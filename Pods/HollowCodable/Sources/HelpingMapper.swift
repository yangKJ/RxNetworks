//
//  HelpingMapper.swift
//  CodableExample
//
//  Created by Condy on 2024/7/24.
//

import Foundation

public class HelpingMapper {
    var codingKeys = [CodingKeyMapping]()
    var replaceKeys = [ReplaceKeys]()
    var nestedKeys = [NestedKeys]()
    var dateKeys = [TransformKeys]()
    var dataKeys = [TransformKeys]()
}

extension HelpingMapper {
    
    static func setupCodingKeyMappingKeys<T: HollowCodable>(_ type: T.Type) -> HelpingMapper {
        let mapper = HelpingMapper()
        T.mapping(mapper: mapper)
        for key in mapper.codingKeys + T.codingKeys {
            switch key {
            case let k as ReplaceKeys:
                mapper.replaceKeys.append(k)
            case let k as NestedKeys:
                mapper.nestedKeys.append(k)
            case let k as TransformKeys:
                switch k.tranformer.objectClassName {
                case "Date":
                    mapper.dateKeys.append(k)
                case "Data":
                    mapper.dataKeys.append(k)
                default:
                    break
                }
            default:
                break
            }
        }
        let hasNestedKeys = mapper.replaceKeys.compactMap {
            $0.hasNestedKeys
        }
        mapper.nestedKeys += hasNestedKeys
        return mapper
    }
}
