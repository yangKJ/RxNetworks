//
//  WarningViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxRelay

class WarningViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<String>()

    func loadData() {
        WarningAPI.warning.request(successed: { [weak self] response in
            guard let response = response.bpm.mappedJson as? String else {
                return
            }
            self?.data.accept(response)
        }, failed: { [weak self] error in
            self?.data.accept(error.localizedDescription)
        })
    }
}
