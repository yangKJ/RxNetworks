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
        return "https://github.com/yangKJ/RxNetworks"
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/blob/master/RxNetworks/Images.xcassets/AppIcon.appiconset/iOS-Marketing.png"
    }
    
    var parameters: APIParameters? {
        return nil
    }
    
    var plugins: APIPlugins {
        switch self {
        case .downloadImage:
            let loading = AnimatedLoadingPlugin(options: .init(delay: 0.5))
            let download = NetworkFilesPlugin(type: .downloadAsset)
            return [loading, download]
        }
    }
}
