//
//  Response+Ext.swift
//  Booming
//
//  Created by Condy on 2024/6/3.
//

import Foundation
import ObjectiveC
import Moya

fileprivate var BoomingResponseJsonContext: UInt8 = 0
fileprivate var BoomingResponseFinishedContext: UInt8 = 0

extension Moya.Response: BoomingCompatible { }

extension BoomingWrapper where Base: Moya.Response {
    
    /// Has been successfully mapped into JSON.
    /// Note: Download file, take the link address from the `mappedJson` parameter.
    public var mappedJson: APIResultValue? {
        get {
            return synchronizedResponse {
                objc_getAssociatedObject(base, &BoomingResponseJsonContext)
            }
        }
        set {
            synchronizedResponse {
                objc_setAssociatedObject(base, &BoomingResponseJsonContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// If the data is returned multiple times, the last return is true.
    /// eg: cache plugin use the `cacheThenNetwork` type.
    public var finished: Bool {
        get {
            return synchronizedResponse {
                if let object = objc_getAssociatedObject(base, &BoomingResponseFinishedContext) as? Bool {
                    return object
                } else {
                    objc_setAssociatedObject(base, &BoomingResponseFinishedContext, false, .OBJC_ASSOCIATION_ASSIGN)
                    return false
                }
            }
        }
        set {
            synchronizedResponse {
                objc_setAssociatedObject(self, &BoomingResponseFinishedContext, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    private func synchronizedResponse<T>( _ action: () -> T) -> T {
        objc_sync_enter(base)
        let result = action()
        objc_sync_exit(base)
        return result
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        if let json = try? toJSON(), let string = X.toJSON(form: json, prettyPrint: prettyPrint) {
            return string
        }
        return nil
    }
    
    public func toJSON() throws -> APIResultValue {
        try toJSONResult().get()
    }
    
    public func toJSONResult() throws -> APIJSONResult {
        do {
            let json = try X.toJSON(with: base)
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
}
