//
//  BatchViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class BatchViewModel: NSObject {
    
    struct Input { }
    
    struct Output {
        let data: Observable<Dictionary<String, Any>>
    }
    
    func transform(input: Input) -> Output {
        let data = batch().asObservable()
        
        return Output(data: data)
    }
    
    func batch() -> Observable<Dictionary<String, Any>> {
        Observable.zip(
            BatchAPI.test.request(),
            BatchAPI.test2("666").request(),
            BatchAPI.test3.request()
        )
        .observe(on: MainScheduler.instance)
        .map({
            AnimatedLoadingPlugin.hideLoadingHUD(view: nil)
            guard let data1 = $0 as? [String: Any],
                  let data2 = $1 as? [String: Any],
                  let data3 = $2 as? Dictionary<String, Any> else {
                return [:]
            }
            let dict = data1 +== data2 +== data3
            return dict
        })
        .catchAndReturn([:])
    }
}
