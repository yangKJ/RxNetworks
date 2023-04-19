//
//  LoadingViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class LoadingViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<NSDictionary>()
    
    func loadData() {
        LoadingAPI.test2("666").request()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if let dict = $0 as? NSDictionary {
                    self?.data.onNext(dict)
                }
            })
            .disposed(by: disposeBag)
    }
}
