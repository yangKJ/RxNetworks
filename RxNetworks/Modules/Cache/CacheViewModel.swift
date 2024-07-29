//
//  CacheViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class CacheViewModel: NSObject {

    struct Input {
        let count: Int
    }

    struct Output {
        let items: Observable<CacheModel>
    }
    
    func transform(input: Input) -> Output {
        let items = request(input.count).asObservable()
        
        return Output(items: items)
    }
}

extension CacheViewModel {
    
    func request(_ count: Int) -> Observable<CacheModel> {
        CacheAPI.cache(count).request()
            .deserialized(CacheModel.self)
            .observe(on: MainScheduler.instance)
    }
}
