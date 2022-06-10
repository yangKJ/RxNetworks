//
//  ClosureViewController.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/6/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks

class ClosureViewController: BaseViewController<ClosureViewModel> {
    
    lazy var textView: UITextView = {
        let view = UITextView.init(frame: CGRect.zero)
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = UIColor.defaultTint
        view.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
    }
    
    func setupUI() {
        self.view.addSubview(textView)
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    func setupViewModel() {
        viewModel.load(success: { [weak self] json in
            self?.textView.text = X.toJSON(form: json, prettyPrint: true) ?? "nil"
        })
    }
}
