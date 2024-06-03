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
import HollowCodable

struct GZipModel: Codable, MappingCodable {
    @Immutable
    var id: Int
    var title: String?
    var imageURL: URL?
    var url: URL?
    
    static var codingKeys: [ReplaceKeys] {
        return [
            ReplaceKeys.init(replaceKey: "imageURL", originalKey: "image"),
            ReplaceKeys.init(replaceKey: "url", originalKey: "github"),
        ]
    }
}

class GZipViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let data = PublishRelay<GZipModel>()
    
    func loadData() {
        GZipAPI.gzip.request()
            .deserialized(ApiResponse<GZipModel>.self, mapping: GZipModel.self)
            .compactMap { $0.data }
            .observe(on: MainScheduler.instance)
            .bind(to: data)
            .disposed(by: disposeBag)
    }
}
