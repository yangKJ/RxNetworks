//
//  OOViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxNetworks

class OOViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<String>()
    
    func loadData() {
        var api = NetworkAPIOO.init()
        api.cdy_ip = NetworkConfig.baseURL
        api.cdy_path = "/ip"
        api.cdy_method = .get
        api.cdy_plugins = [NetworkLoadingPlugin.init()]
        api.cdy_retry = 3
        
        api.cdy_HTTPRequest()
            .asObservable()
            .compactMap{ (($0 as! NSDictionary)["origin"] as? String) }
            .catchAndReturn("")
            .bind(to: data)
            .disposed(by: disposeBag)
    }
}
