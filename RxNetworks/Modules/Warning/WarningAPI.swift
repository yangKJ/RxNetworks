//
//  WarningAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks
import NetworkHudsPlugin

enum WarningAPI {
    case warning
}

extension WarningAPI: NetworkAPI {
    
    var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/failed/path"
    }
    
    var plugins: APIPlugins {
        var options = NetworkWarningPlugin.Options.init(duration: 2)
        options.setChangeHudParameters { hud in
            guard let superview = hud.superview else { return }
            hud.center = CGPoint(x: superview.center.x, y: superview.frame.height - 100)
        }
        let warning = NetworkWarningPlugin.init(options: options)
        let loading = NetworkLoadingPlugin.init(options: .init(delay: 0.5))
        let header = NetworkHttpHeaderPlugin.init(headers: [
            HTTPHeader.init(name: "test header", value: "Condy_77")
        ])
        return [loading, warning, header]
    }
}
