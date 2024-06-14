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
    
    @MainActor
    func request(block: @escaping (_ text: String?) -> Void) {
        Task {
            do {
                let response = try await LoadingAPI.test2("666").requestAsync()
                let json = response.bpm.mappedJson
                let model = Deserialized<LoadingModel>.toModel(with: json)
                block(model?.toJSONString(prettyPrint: true))
            } catch {
                block(error.localizedDescription)
            }
        }
    }
}
