//
//  CacheAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum CacheAPI: NetworkAPI {
    case cache(Int)
    
    var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        switch self {
        case .cache(let c):
            return ["count": "\(c)"]
        }
    }
    
    var plugins: APIPlugins {
        let cache = NetworkCachePlugin.init(options: .cacheThenNetwork)
        let loading = NetworkLoadingPlugin.init(options: .init(text: "Cacheing..", delay: 0.5))
        return [loading, cache]
    }
}
