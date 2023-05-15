//
//  TokenAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import RxNetworks

enum TokenAPI {
    case auth
}

extension TokenAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin(autoHide: false)
        let token = TokenPlugin.shared
        return [token, loading]
    }
}
