//
//  AnimatedLoadingAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import RxNetworks

enum AnimatedLoadingAPI {
    case loading(String)
}

extension AnimatedLoadingAPI: NetworkAPI {
    
    var ip: APIHost {
        return BoomingSetup.baseURL
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
        let loading = AnimatedLoadingPlugin(options: .init(delay: 1.2))
        return [loading]
    }
}
