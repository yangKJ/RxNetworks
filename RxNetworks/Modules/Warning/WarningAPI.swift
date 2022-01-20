//
//  WarningAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum WarningAPI {
    case warning
}

extension WarningAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/pos"
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin.init()
        let warning = NetworkWarningPlugin.init()
        warning.changeHud = { (hud) in
            hud.detailsLabel.textColor = UIColor.yellow
        }
        return [loading, warning]
    }
}
