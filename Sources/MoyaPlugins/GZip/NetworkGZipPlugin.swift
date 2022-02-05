//
//  NetworkGZipPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/8.
//

import Foundation
import Moya

/// 解压缩插件，只能解开`GZip`压缩数据
/// GZip plugin, Can only unpack `GZip` compressed data.
public final class NetworkGZipPlugin {
    
    public init() { }
}

extension NetworkGZipPlugin: PluginSubType {
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if case .success(let response) = result {
            // Can only unpack GZip compressed data
            guard GZipManager.isGZipCompressed(response.data) else {
                return result
            }
            let data = GZipManager.gzipUncompress(response.data)
            let _response = Response(statusCode: response.statusCode,
                                     data: data,
                                     request: response.request,
                                     response: response.response)
            return .success(_response)
        }
        return result
    }
}
