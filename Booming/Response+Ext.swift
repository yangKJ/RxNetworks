//
//  Response+Ext.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import Moya

extension Moya.Response: Codable {
    
    public enum CodingKeys: CodingKey {
        case statusCode
        case data
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statusCode = try container.decode(Int.self, forKey: CodingKeys.statusCode)
        let data = try container.decode(Data.self, forKey: CodingKeys.data)
        self.init(statusCode: statusCode, data: data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: CodingKeys.statusCode)
        try container.encode(data, forKey: CodingKeys.data)
    }
    
    public func toJSON() throws -> APIJSONResult {
        do {
            let json = try X.toJSON(with: self)
            return .success(json)
        } catch MoyaError.statusCode(let response) {
            let error = MoyaError.statusCode(response)
            return .failure(error)
        } catch MoyaError.jsonMapping(let response) {
            let error = MoyaError.jsonMapping(response)
            return .failure(error)
        } catch MoyaError.stringMapping(let response) {
            let error = MoyaError.stringMapping(response)
            return .failure(error)
        } catch {
            return .failure(MoyaError.underlying(error, nil))
        }
    }
}
