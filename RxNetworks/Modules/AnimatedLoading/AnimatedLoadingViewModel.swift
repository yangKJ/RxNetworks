//
//  AnimatedLoadingViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class AnimatedLoadingViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<String?>()
    
    func loadData() {
        let loadingApi = AnimatedLoadingAPI.loading("Condy")
        loadingApi.request()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { ($0 as? NSDictionary)?["data"] as? String }
            .subscribe(onNext: { [weak self] in
                self?.data.onNext($0)
                if let plugin = loadingApi.givenPlugin(type: AnimatedLoadingPlugin.self) {
                    plugin.hideLoadingHUD()
                }
            }).disposed(by: disposeBag)
    }
}
