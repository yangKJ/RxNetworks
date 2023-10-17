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
        case .test2(let string):
            return ["key": string]
        }
    }
    
    var plugins: APIPlugins {
        var options = NetworkLoadingPlugin.Options.init(delay: 2)
        options.setChangeHudParameters { hud in
            hud.detailsLabel.text = "Loading"
            hud.detailsLabel.textColor = UIColor.yellow
        }
        let loading = NetworkLoadingPlugin.init(options: options)
        return [loading]
    }
}
