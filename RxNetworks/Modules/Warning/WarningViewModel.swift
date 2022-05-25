//
//  WarningViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class WarningViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishSubject<String>()

    func loadData() {
        WarningAPI.warning.request()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { $0 as! String }
            .catchAndReturn("catch and return.")
            .subscribe(data)
            .disposed(by: disposeBag)
    }
}
