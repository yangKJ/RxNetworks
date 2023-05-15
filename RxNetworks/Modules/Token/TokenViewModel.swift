//
//  TokenViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class TokenViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data: PublishRelay<NSDictionary> = PublishRelay()
    
    func loadData() {
        TokenAPI.auth.request()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                NetworkLoadingPlugin.hideMBProgressHUD()
                if let dict = $0 as? NSDictionary {
                    self?.data.accept(dict)
                }
            })
            .disposed(by: disposeBag)
    }
}
