//
//  DownloadViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2023/4/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RxNetworks
import RxCocoa

class DownloadViewController: BaseViewController<DownloadViewModel> {
    
    lazy var imageView: UIImageView = {
        let width = view.bounds.size.width-40
        let rect = CGRect(x: 20, y: 100, width: width, height: width)
        let imageView = UIImageView(frame: rect)
        imageView.center = self.view.center
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.purple.cgColor
        imageView.layer.borderWidth = 2
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupBindings()
    }
    
    func setupUI() {
        self.view.addSubview(imageView)
    }
    
    func setupBindings() {
        viewModel.image
            .bind(to: self.imageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.loadData()
    }
}
