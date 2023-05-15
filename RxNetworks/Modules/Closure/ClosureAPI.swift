//
//  ClosureAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/6/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum ClosureAPI {
    case userInfo(name: String)
}

extension ClosureAPI: NetworkAPI {
    
    var ip: APIHost {
        return "https://api.github.com"
    }
    
    var path: APIPath {
        switch self {
        case .userInfo(let name):
            return "/users/\(name)"
        }
    }
    
    var method: APIMethod {
        return APIMethod.get
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin.init(text: "Loading..", delay: 0.5)
        return [loading]
    }
}
