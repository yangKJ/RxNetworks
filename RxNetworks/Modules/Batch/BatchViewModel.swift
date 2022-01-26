//
//  BatchViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxNetworks

class BatchViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<Dictionary<String, Any>>()
    
    func batchLoad() {
        Observable.zip(
            BatchAPI.test.request(),
            BatchAPI.test2("666").request(),
            BatchAPI.test3.request()
        ).subscribe(onNext: { [weak self] in
            NetworkLoadingPlugin.hideMBProgressHUD()
            guard var data1 = $0 as? Dictionary<String, Any>,
                  let data2 = $1 as? Dictionary<String, Any>,
                  let data3 = $2 as? Dictionary<String, Any> else {
                      return
                  }
            data1 += data2
            data1 += data3
            self?.data.accept(data1)
        }, onError: {
            print("Network Failed: \($0)")
        }).disposed(by: disposeBag)
    }
}
