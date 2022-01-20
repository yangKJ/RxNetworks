//
//  NetworkIndicatorPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import Moya

/// 指示器插件，该插件已被设置为全局使用
/// Indicator plug-in, the plug-in has been set for global use
public final class NetworkIndicatorPlugin {
    
    private static var numberOfRequests: Int = 0 {
        didSet {
            if numberOfRequests > 1 { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.numberOfRequests > 0
            }
        }
    }
    
    public init() { }
}

extension NetworkIndicatorPlugin: PluginSubType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        NetworkIndicatorPlugin.numberOfRequests += 1
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        NetworkIndicatorPlugin.numberOfRequests -= 1
    }
}
