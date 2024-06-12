//
//  TokenAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import RxNetworks
import NetworkHudsPlugin

enum TokenAPI {
    case auth
}

extension TokenAPI: NetworkAPI {
    
    var ip: APIHost {
        return "https://www.httpbin.org"
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/headers"
    }
    
    static var index: Int = 0
    
    var plugins: APIPlugins {
        switch self {
        case .auth:
            var options = NetworkTokenPlugin.Options.init(addToken: {
                ["Authorization": TokenManager.shared.token]
            }, reacquireToken: { blcok in
                TokenManager.shared.reqLogin(complete: blcok)
            })
            /// 模拟token失效
            options.setTokenInvalidBlock(block: { (error, reponse) -> Bool in
                Self.index += 1
                return ((Self.index % 3) != 0) ? true : false
            })
            let token = NetworkTokenPlugin(options: options)
            let loading = NetworkLoadingPlugin(options: .dontAutoHide)
            let ignore = NetworkIgnorePlugin(pluginTypes: [
                NetworkAuthenticationPlugin.self,
                AuthPlugin.self,
            ])
            return [token, loading, ignore]
        }
    }
}
