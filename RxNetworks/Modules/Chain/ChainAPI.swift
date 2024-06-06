//
//  ChainAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks
import NetworkLottiePlugin

enum ChainAPI {
    case test
    case test2(String)
}

extension ChainAPI: NetworkAPI {
    
    var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    var path: APIPath {
        switch self {
        case .test:
            return "/ip"
        case .test2:
            return "/delay/2"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .test: 
            return .get
        case .test2: 
            return .post
        }
    }
    
    var parameters: APIParameters? {
        switch self {
        case .test: 
            return nil
        case .test2(let ip):
            return ["ip": ip]
        }
    }
    
    var plugins: APIPlugins {
        ((arc4random() % 2) != 0) ? loadingPlugins : lottiePlugins
    }
    
    var loadingPlugins: APIPlugins {
        switch self {
        case .test:
            let loading = NetworkLoadingPlugin(options: .dontAutoHide)
            return [loading]
        case .test2(_):
            let loading = NetworkLoadingPlugin(options: .init(text: "loading..", delay: 1))
            return [loading]
        }
    }
    
    var lottiePlugins: APIPlugins {
        switch self {
        case .test:
            let loading = AnimatedLoadingPlugin(options: .dontAutoHide)
            return [loading]
        case .test2:
            let loading = AnimatedLoadingPlugin(options: .init(text: "loading..", delay: 1))
            return [loading]
        }
    }
}
