//
//  OOViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class OOViewModel: NSObject {
    
    func request() -> Observable<String> {
        let api = NetworkAPIOO.init()
        api.ip = "https://www.httpbin.org"
        api.path = "/ip"
        api.method = APIMethod.get
        api.plugins = [NetworkLoadingPlugin()]
        api.retry = 2
        return api.request()
            .compactMap{ (($0 as? NSDictionary)?["origin"] as? String) }
            .catchAndReturn("")
            .observe(on: MainScheduler.instance)
    }
}
