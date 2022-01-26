//
//  BatchAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum BatchAPI {
    case test
    case test2(String)
    case test3
}

extension BatchAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var path: APIPath {
        switch self {
        case .test:
            return "/ip"
        case .test2:
            return "/uuid"
        case .test3:
            return "/user-agent"
        }
    }
    
    var method: APIMethod {
        return APIMethod.get
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin(autoHide: false)
        return [loading]
    }
    
    var stubBehavior: APIStubBehavior {
        switch self {
        case .test3:
            return APIStubBehavior.delayed(seconds: 2)
        default:
            return APIStubBehavior.never
        }
    }
    
    var sampleData: Data {
        let dict: [String : Any] = [
            "data": "delayed 2 seconds return data.",
            "code": 200,
            "message": "successed."
        ]
        return X.toJSON(form: dict)!.data(using: String.Encoding.utf8)!
    }
}
