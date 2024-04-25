//
//  DownloadViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class DownloadViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    let image = PublishSubject<UIImage?>()
    
    func loadData() {
        DownloadAPI.downloadImage.request()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .compactMap {
                guard let url = $0 as? URL else {
                    return nil
                }
                if #available(iOS 16.0, *) {
                    let image = UIImage(contentsOfFile: url.path())
                    return image
                } else {
                    let image = UIImage(contentsOfFile: url.path)
                    return image
                }
            }
            .bind(to: self.image)
            .disposed(by: disposeBag)
    }
}
