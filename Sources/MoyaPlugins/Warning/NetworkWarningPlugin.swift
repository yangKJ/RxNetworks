//
//  NetworkWarningPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import Moya
import MBProgressHUD

/// 自动提示插件
/// Indicator plug-in, the plug-in has been set for global use
public final class NetworkWarningPlugin {
    
    public init() { }
}

extension NetworkWarningPlugin: PluginSubType {
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(_):
            break
        case let .failure(error):
            print(error.localizedDescription)
        }
    }
}
