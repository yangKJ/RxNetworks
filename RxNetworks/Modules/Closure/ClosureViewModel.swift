//
//  ClosureViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/6/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

class ClosureViewModel: NSObject {
    
    func load(success: @escaping (APISuccessJSON) -> Void) {
        ClosureAPI.userInfo(name: "yangKJ").request(successed: { json, _, _ in
            success(json)
        }, failed: { error in
            print(error.localizedDescription)
        })
    }
}
