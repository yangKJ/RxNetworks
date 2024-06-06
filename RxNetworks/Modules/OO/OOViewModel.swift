//
//  OOViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class OOViewModel: NSObject {
    
    let result = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    func request() {
        let api = NetworkAPIOO.init()
        api.ip = "https://www.httpbin.org"
        api.path = "/headers"
        api.method = APIMethod.get
        api.plugins = [NetworkLoadingPlugin(options: .init(text: "OOing.."))]
        api.retry = 2
        api.request()
            .observe(on: MainScheduler.instance)
            .compactMap{ X.toJSON(form: $0, prettyPrint: true) }
            .catchAndReturn("")
            .bind(to: result)
            .disposed(by: disposeBag)
    }
}
