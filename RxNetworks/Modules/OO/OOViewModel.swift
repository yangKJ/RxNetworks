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
    
    struct Input {
        let retry: Int
    }
    
    struct Output {
        let items: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        return Output(items: input.request())
    }
}

extension OOViewModel.Input {
    func request() -> Observable<String> {
        var api = NetworkAPIOO.init()
        api.cdy_ip = NetworkConfig.baseURL
        api.cdy_path = "/ip"
        api.cdy_method = APIMethod.get
        api.cdy_plugins = [NetworkLoadingPlugin()]
        api.cdy_retry = self.retry
        
        return api.cdy_HTTPRequest()
            .asObservable()
            .compactMap{ (($0 as! NSDictionary)["origin"] as? String) }
            .catchAndReturn("")
            .observe(on: MainScheduler.instance)
    }
}
