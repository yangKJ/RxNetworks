//
//  SharedViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class SharedViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<String>()
    
    // 模拟多次请求同一网络
    func testImitateMoreNetwork() {
        for index in 0...5 {
            SharedAPI.loading("Condy")
                .request()
                .map { ($0 as? NSDictionary)?["data"] as? String }
                .subscribe(onNext: { [weak self] in
                    print("\(index) --- \($0 ?? "")")
                    self?.data.accept("\(index) --- \($0 ?? "")")
                }).disposed(by: disposeBag)
        }
    }
}
