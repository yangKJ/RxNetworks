//
//  WarningViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxNetworks

class WarningViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<String>()
    
    func loadData() {
        WarningAPI.warning.request()
            .asObservable()
            .map { $0 as! String }
            .catchAndReturn("catch and return.")
            .bind(to: data)
            .disposed(by: disposeBag)
    }
}
