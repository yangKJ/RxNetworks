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
import HollowCodable

class LoadingViewModel: NSObject {
    
    @MainActor
    func request(block: @escaping (_ text: String?) -> Void) {
        Task {
            do {
                let response = try await LoadingAPI.test2("10").requestAsync()
                let json = response.bpm.mappedJson
                //let model = ApiResponse<LoadingModel>.deserialize(from: json, options: .CodingKeysConvertFromSnakeCase)?.data
                let model = LoadingModel.deserialize(from: json, designatedPath: "data", options: .CodingKeysConvertFromSnakeCase)
                block(model?.toJSONString(prettyPrint: true))
            } catch {
                block(error.localizedDescription)
            }
        }
    }
}
