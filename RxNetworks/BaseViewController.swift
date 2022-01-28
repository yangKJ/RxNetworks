//
//  BaseViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2021/10/2.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController<VM: NSObject>: UIViewController {

    public lazy var viewModel: VM = VM.init()
    public let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.background
    }
    
    deinit {
        print("🎷\(String(describing: self)): Deinited")
    }
}

extension UIColor {
    static let background = UIColor(named: "background")
    static let defaultTint = UIColor(named: "defaultTint")
    static let cell_background = UIColor(named: "cell_background")
}
