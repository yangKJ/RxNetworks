//
//  GZipAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum GZipAPI {
    case gzip
}

extension GZipAPI: NetworkAPI {
    
    var ip: APIHost {
        return "https://www.httpbin.org"
    }
    
    var method: APIMethod {
        return APIMethod.post
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var plugins: APIPlugins {
        let gzip = NetworkGZipPlugin.init()
        let loading = NetworkLoadingPlugin.init(text: "UnGZiping..")
        return [loading, gzip]
    }
    
    var stubBehavior: APIStubBehavior {
        return .delayed(seconds: 0.5)
    }
    
    var sampleData: Data {
        let data: [String : Any] = [
            "id": 7,
            "title": "Network Framework",
            "image": "https://upload-images.jianshu.io/upload_images/1933747-4bc58b5a94713f99.jpeg",
            "github": "https://github.com/yangKJ/RxNetworks"
        ]
        let dict: [String : Any] = [
            "data": data,
            "code": 200,
            "message": "successed."
        ]
        let jsonData = X.toJSON(form: dict)!.data(using: String.Encoding.utf8)!
        return GZipManager.gzipCompress(jsonData)
    }
}
