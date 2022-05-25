//
//  GZipViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class GZipViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<String>()
    
    func loadData() {
        GZipAPI.gzip.request()
            .asObservable()
            .mapHandyJSON(HandyDataModel<CacheModel>.self)
            .map { ($0.data?.url)! }
            .observe(on: MainScheduler.instance)
            .catchAndReturn("")
            .subscribe(data)
            .disposed(by: disposeBag)
    }
}
