//
//  ClosureViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/6/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

class ClosureViewModel: NSObject {
    
    func load(success: @escaping APISuccess) {
        ClosureAPI.userInfo(name: "yangKJ").HTTPRequest(success: { json in
            success(json)
        }, failure: { error in
            print(error.localizedDescription)
        })
    }
}
