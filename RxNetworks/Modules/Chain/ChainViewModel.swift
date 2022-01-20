//
//  ChainViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxNetworks

class ChainViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<NSDictionary>()
    
    func chainLoad() {
        requestIP()
            .flatMapLatest(requestData)
            .subscribe(onNext: { [weak self] data in
                self?.data.accept(data)
            }, onError: {
                print("Network Failed: \($0)")
            }).disposed(by: disposeBag)
    }
}

extension ChainViewModel {
    
    func requestIP() -> Observable<String> {
        return ChainAPI.test.request()
            .asObservable()
            .map { ($0 as! NSDictionary)["origin"] as! String }
            .catchAndReturn("") // 异常抛出
    }
    
    func requestData(_ ip: String) -> Single<NSDictionary> {
        return ChainAPI.test2(ip).request()
            .map { ($0 as! NSDictionary) }
            .catchAndReturn(["data": "nil"])
    }
}
