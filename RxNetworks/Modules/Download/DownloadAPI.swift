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
        //return NetworkConfig.baseURL
        //return "https://nr-platform.s3.amazonaws.com"
        return "https://raw.githubusercontent.com"
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        //return "/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"
        return "/yangKJ/ImageX/master/Images/IMG_3960.heic"
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
