//
//  LoadingAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks
import NetworkHudsPlugin

enum LoadingAPI {
    case test2(String)
}

extension LoadingAPI: NetworkAPI {
    
    var ip: APIHost {
        //return "https://haokan.baidu.com/web"
        return "https://haokan.baidu.com/web/author/listall?rn=10&ctime=17190335423453&app_id=1727467477413519"
    }
    
    var method: APIMethod {
        return .get
    }
    
//    var path: APIPath {
//        return "/author/listall"
//    }
//    
//    var parameters: APIParameters? {
//        switch self {
//        case .test2(let string):
//            return [
//                "rn": string,
//                "ctime": "17190335423453",
//                "app_id": "1727467477413519",
//            ]
//        }
//    }
    
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
