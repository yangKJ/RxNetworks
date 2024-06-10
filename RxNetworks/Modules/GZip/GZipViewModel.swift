//
//  GZipViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa
import HandyJSON

struct GZipModel: HandyJSON {
    var id: Int?
    var title: String?
    var imageURL: String?
    var url: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            imageURL <-- "image"
        mapper <<<
            url <-- "github"
    }
}

class GZipViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<GZipModel>()
    
    func loadData() {
        GZipAPI.gzip.request()
            .mapHandyJSON(HandyDataModel<GZipModel>.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance)
            .bind(to: data)
            .disposed(by: disposeBag)
    }
}
