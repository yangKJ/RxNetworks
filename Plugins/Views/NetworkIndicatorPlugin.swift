//
//  NetworkIndicatorPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

#if canImport(UIKit)
import UIKit

/// 指示器插件，该插件已被设置为全局使用
/// Indicator plug-in, the plug-in has been set for global use
public final class NetworkIndicatorPlugin {
    
    public static let shared = NetworkIndicatorPlugin()
    
    private var numberOfRequests: Int = 0 {
        didSet {
            if numberOfRequests > 1 { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.numberOfRequests > 0
            }
        }
    }
    
    private init() { }
}

extension NetworkIndicatorPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Indicator"
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        NetworkIndicatorPlugin.shared.numberOfRequests += 1
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        NetworkIndicatorPlugin.shared.numberOfRequests -= 1
    }
}

#endif
