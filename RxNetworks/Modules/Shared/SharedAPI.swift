//
//  SharedAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import RxNetworks

enum SharedAPI {
    case loading(String)
}

extension SharedAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var method: APIMethod {
        return .post
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        switch self {
        case .loading(let string): return ["key": string]
        }
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin.init()
        let shared = NetworkSharedPlugin()
        return [loading, shared]
    }
}
