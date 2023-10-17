//
//  AnimatedLoadingViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class AnimatedLoadingViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<String?>()
    
    func loadData() {
        AnimatedLoadingAPI.loading("Condy").request()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { ($0 as? NSDictionary)?["data"] as? String }
            .bind(to: self.data)
            .disposed(by: disposeBag)
    }
}
