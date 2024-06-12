//
//  LoadingViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Booming
import RxNetworks

class LoadingViewModel: NSObject {
    
    func request(block: @escaping (_ text: String?) -> Void) {
        LoadingAPI.test2("666").request(successed: { json, _, _ in
            if let model = Deserialized<LoadingModel>.toModel(with: json) {
                block(model.origin)
            }
        }, failed: { error in
            block(error.localizedDescription)
        })
    }
}
