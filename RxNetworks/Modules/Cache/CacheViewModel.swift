//
//  CacheViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class CacheViewModel: NSObject {

    let disposeBag = DisposeBag()
    
    struct Input {
        let count: Int
    }

    struct Output {
        let items: Driver<[CacheModel]>
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[CacheModel]>(value: [])
        
        let output = Output(items: elements.asDriver())
        
        request(input.count).drive(elements).disposed(by: disposeBag)
        
        return output
    }
}

extension CacheViewModel {
    
    func request(_ count: Int) -> Driver<[CacheModel]> {
        CacheAPI.cache(count).request()
            .mapHandyJSON(HandyDataModel<[CacheModel]>.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance) // 结果在主线程返回
            .delay(.seconds(1), scheduler: MainScheduler.instance) // 延时1秒返回
            .asDriver(onErrorJustReturn: []) // 错误时刻返回空
    }
}
