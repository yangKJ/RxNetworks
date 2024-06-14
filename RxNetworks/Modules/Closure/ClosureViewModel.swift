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
        ClosureAPI.userInfo(name: "yangKJ").request(successed: { response in
            guard let string = response.bpm.toJSONString(prettyPrint: true) else {
                return
            }
            success(string)
        }, failed: { error in
            print(error.localizedDescription)
        })
    }
}
