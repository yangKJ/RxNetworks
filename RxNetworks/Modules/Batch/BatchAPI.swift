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
            return "/user-agent"
        case .test3:
            return "/uuid"
        }
    }
    
    var method: APIMethod {
        return .get
    }
}
