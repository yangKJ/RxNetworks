//
//  DownloadAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import RxNetworks

enum DownloadAPI {
    case downloadImage
}

extension DownloadAPI: NetworkAPI {
    
    var ip: APIHost {
        return "https://media.gcflearnfree.org"
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/content/588f55e5a0b0042cb858653b_01_30_2017/images_stock_puppy.jpg"
    }
    
    var parameters: APIParameters? {
        return nil
    }
    
    var plugins: APIPlugins {
        switch self {
        case .downloadImage:
            let loading = NetworkLoadingPlugin(options: .init(text: "Loading..", delay: 0.5))
            let download = NetworkFilesPlugin(type: .downloadAsset)
            let ignore = NetworkIgnorePlugin(pluginTypes: [NetworkAuthenticationPlugin.self])
            return [loading, download, ignore]
        }
    }
}
