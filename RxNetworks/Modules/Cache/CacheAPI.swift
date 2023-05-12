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
        return "https://www.httpbin.org"
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        return ["test": "x12345"]
    }
    
    var plugins: APIPlugins {
        let cache = NetworkCachePlugin.init(options: .cacheElseNetwork)
        let loading = NetworkLoadingPlugin.init(delay: 0.5)
        return [loading, cache]
    }
    
    var stubBehavior: APIStubBehavior {
        return .delayed(seconds: 0.5)
    }
    
    var sampleData: Data {
        switch self {
        case .cache:
            return X.jsonData("AMList")!
        }
    }
}
