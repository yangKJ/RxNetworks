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
        LoadingAPI.test2("666").request(complete: { result in
            switch result {
            case .success(let json):
                if let model = Deserialized<LoadingModel>.toModel(with: json) {
                    DispatchQueue.main.async {
                        block(model.origin)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    block(error.localizedDescription)
                }
            }
        })
    }
}
