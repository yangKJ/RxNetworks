//
//  LoadingAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum LoadingAPI {
    case test2(String)
}

extension LoadingAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        switch self {
        case .test2(let string): return ["key": string]
        }
    }
}
